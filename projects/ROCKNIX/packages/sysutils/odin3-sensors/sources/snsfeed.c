/*
 * snsclient.c - minimal, self-contained QMI-over-QRTR client for the
 * Qualcomm Snapdragon Sensor Core "sns_client" service (QMI id 400).
 *
 * PoC: resolve a sensor SUID by data_type ("accel"/"gyro") and then stream
 * samples. Hand-rolled protobuf + QMI framing, no external libraries — only
 * the kernel QRTR UAPI. Protocol values taken from the public libssc RE
 * (Dylan Van Assche) and the Qualcomm sns_client_api_v01 constants.
 *
 * Usage: snsclient <data_type> [seconds] [rate_hz]
 *   e.g. snsclient accel 3 50   -> stream accel at 50Hz for 3s
 *        snsclient gyro         -> just resolve the gyro SUID and exit
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <time.h>
#include <sys/socket.h>
#include <linux/qrtr.h>

typedef int s32;
typedef struct { s32 v[6]; } s32vals;

#ifndef AF_QRTR
#define AF_QRTR 42
#endif

/* --- SSC / QMI constants --- */
#define SSC_SVC_ID              400
#define QMI_SNS_REQ_MSG_ID      0x0020
#define QMI_SNS_IND_SMALL       0x0022
#define QMI_SNS_IND_JUMBO       0x0023
#define QMI_TLV_PAYLOAD         0x01

#define SUID_ABAB               0xABABABABABABABABULL
#define MSG_REQUEST_SUID        512
#define MSG_REQUEST_ENABLE_CONT 513
#define MSG_RESPONSE_SUID       768
#define MSG_REPORT_MEASUREMENT  1025

/* ---------------- protobuf encoder ---------------- */
struct buf { uint8_t *p; size_t len, cap; };

static void b_init(struct buf *b) { b->cap = 256; b->len = 0; b->p = malloc(b->cap); }
static void b_need(struct buf *b, size_t n) {
	if (b->len + n > b->cap) { while (b->len + n > b->cap) b->cap *= 2; b->p = realloc(b->p, b->cap); }
}
static void b_byte(struct buf *b, uint8_t v) { b_need(b, 1); b->p[b->len++] = v; }
static void b_raw(struct buf *b, const void *d, size_t n) { b_need(b, n); memcpy(b->p + b->len, d, n); b->len += n; }
static void b_varint(struct buf *b, uint64_t v) {
	do { uint8_t x = v & 0x7f; v >>= 7; if (v) x |= 0x80; b_byte(b, x); } while (v);
}
static void pb_tag(struct buf *b, int field, int wt) { b_varint(b, ((uint64_t)field << 3) | wt); }
static void pb_varfield(struct buf *b, int field, uint64_t v) { pb_tag(b, field, 0); b_varint(b, v); }
static void pb_fixed64(struct buf *b, int field, uint64_t v) { pb_tag(b, field, 1); b_raw(b, &v, 8); }
static void pb_fixed32(struct buf *b, int field, uint32_t v) { pb_tag(b, field, 5); b_raw(b, &v, 4); }
static void pb_bytes(struct buf *b, int field, const void *d, size_t n) {
	pb_tag(b, field, 2); b_varint(b, n); b_raw(b, d, n);
}

/* ---------------- protobuf decoder ---------------- */
struct pb { const uint8_t *p, *end; };
static int pb_read_tag(struct pb *s, int *field, int *wt) {
	if (s->p >= s->end) return 0;
	uint64_t t = 0; int sh = 0;
	while (s->p < s->end) { uint8_t x = *s->p++; t |= (uint64_t)(x & 0x7f) << sh; if (!(x & 0x80)) break; sh += 7; }
	*field = t >> 3; *wt = t & 7; return 1;
}
static uint64_t pb_read_varint(struct pb *s) {
	uint64_t v = 0; int sh = 0;
	while (s->p < s->end) { uint8_t x = *s->p++; v |= (uint64_t)(x & 0x7f) << sh; if (!(x & 0x80)) break; sh += 7; }
	return v;
}
static uint64_t pb_read_fixed64(struct pb *s) { uint64_t v = 0; if (s->p + 8 <= s->end) { memcpy(&v, s->p, 8); s->p += 8; } return v; }
static uint32_t pb_read_fixed32(struct pb *s) { uint32_t v = 0; if (s->p + 4 <= s->end) { memcpy(&v, s->p, 4); s->p += 4; } return v; }
/* returns pointer+len of a length-delimited field, advancing s */
static const uint8_t *pb_read_bytes(struct pb *s, size_t *n) {
	uint64_t l = pb_read_varint(s); const uint8_t *d = s->p;
	if (s->p + l > s->end) l = s->end - s->p;
	s->p += l; *n = l; return d;
}
static void pb_skip(struct pb *s, int wt) {
	size_t n; switch (wt) {
	case 0: pb_read_varint(s); break;
	case 1: s->p += 8; break;
	case 2: pb_read_bytes(s, &n); break;
	case 5: s->p += 4; break;
	}
}

/* ---------------- QRTR helpers ---------------- */
static int qrtr_open(void) {
	int s = socket(AF_QRTR, SOCK_DGRAM, 0);
	if (s < 0) { perror("socket(AF_QRTR)"); exit(1); }
	return s;
}
/* find service node:port via NEW_LOOKUP */
static int qrtr_lookup(int s, unsigned svc, struct sockaddr_qrtr *out) {
	struct qrtr_ctrl_pkt pkt; struct sockaddr_qrtr sq, from; socklen_t sl = sizeof(sq), fl;
	struct timeval tv = { .tv_sec = 2 };
	getsockname(s, (struct sockaddr *)&sq, &sl);
	memset(&pkt, 0, sizeof(pkt));
	pkt.cmd = QRTR_TYPE_NEW_LOOKUP;
	pkt.server.service = svc;
	sq.sq_port = QRTR_PORT_CTRL;
	sendto(s, &pkt, sizeof(pkt), 0, (struct sockaddr *)&sq, sizeof(sq));
	setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));
	for (;;) {
		fl = sizeof(from);
		int n = recvfrom(s, &pkt, sizeof(pkt), 0, (struct sockaddr *)&from, &fl);
		if (n <= 0) return -1;
		if (pkt.cmd != QRTR_TYPE_NEW_SERVER) continue;
		if (!pkt.server.service && !pkt.server.node) return -1; /* end */
		if (pkt.server.service == svc) {
			memset(out, 0, sizeof(*out));
			out->sq_family = AF_QRTR;
			out->sq_node = pkt.server.node;
			out->sq_port = pkt.server.port;
			return 0;
		}
	}
}

/* ---------------- build the SscClientRequest ---------------- */
/* request->msg (SscClientRequestBody.msg, field 2) carries the sensor-specific payload */
static void build_client_request(struct buf *out, uint64_t uid_lo, uint64_t uid_hi,
				 uint32_t msg_id, const uint8_t *inner, size_t inner_len) {
	struct buf uid, cfg, body;
	b_init(&uid); pb_fixed64(&uid, 1, uid_lo); pb_fixed64(&uid, 2, uid_hi);
	b_init(&cfg); pb_varfield(&cfg, 1, 1); pb_varfield(&cfg, 2, 0); /* processor=APSS, suspend=WAKEUP */
	b_init(&body); if (inner) pb_bytes(&body, 2, inner, inner_len);  /* SscClientRequestBody.msg = field 2 */

	b_init(out);
	pb_bytes(out, 1, uid.p, uid.len);      /* uid (SscUid) */
	pb_fixed32(out, 2, msg_id);            /* msg_id (fixed32) */
	pb_bytes(out, 3, cfg.p, cfg.len);      /* config */
	pb_bytes(out, 4, body.p, body.len);    /* request (SscClientRequestBody) */
	free(uid.p); free(cfg.p); free(body.p);
}

/* wrap a packed SscClientRequest in a QMI request SDU.
 * mode selects the mandatory-TLV framing (RE unknowns): tlv_type + inner len prefix width. */
static int g_mode = 0;
static size_t build_qmi(uint8_t *dst, uint16_t txn, const uint8_t *pb, size_t pblen) {
	uint8_t tlv_type; int prefix; /* prefix: 0=none, 2=u16, 4=u32 */
	switch (g_mode) {
	default:
	case 0: tlv_type = 0x01; prefix = 4; break;
	case 1: tlv_type = 0x01; prefix = 0; break;
	case 2: tlv_type = 0x01; prefix = 2; break;
	case 3: tlv_type = 0x02; prefix = 2; break;
	case 4: tlv_type = 0x02; prefix = 0; break;
	}
	uint8_t *q = dst;
	uint16_t tlv_len = prefix + pblen;
	uint16_t msg_len = 1 + 2 + tlv_len;
	*q++ = 0x00;
	memcpy(q, &txn, 2); q += 2;
	uint16_t mid = QMI_SNS_REQ_MSG_ID; memcpy(q, &mid, 2); q += 2;
	memcpy(q, &msg_len, 2); q += 2;
	*q++ = tlv_type;
	memcpy(q, &tlv_len, 2); q += 2;
	if (prefix == 4) { uint32_t v = pblen; memcpy(q, &v, 4); q += 4; }
	else if (prefix == 2) { uint16_t v = pblen; memcpy(q, &v, 2); q += 2; }
	memcpy(q, pb, pblen); q += pblen;
	return q - dst;
}
/* read the QMI result code from a response SDU (TLV 0x02 = {u16 result, u16 error}) */
static int qmi_result(const uint8_t *sdu, size_t n, int *err) {
	if (n < 7) return -1;
	const uint8_t *p = sdu + 7, *end = sdu + n;
	while (p + 3 <= end) {
		uint8_t t = p[0]; uint16_t l = p[1] | (p[2] << 8); p += 3;
		if (p + l > end) break;
		if (t == 0x02 && l >= 4) { int res = p[0] | (p[1] << 8); if (err) *err = p[2] | (p[3] << 8); return res; }
		p += l;
	}
	return -1;
}

/* extract the payload-protobuf out of a QMI indication SDU.
 * On SM8750 the report indication (msg_id 0x0021) carries the protobuf in
 * TLV 0x02 as [u16 pb_len][protobuf]; TLV 0x01 is an 8-byte client handle. */
static const uint8_t *qmi_indication_payload(const uint8_t *sdu, size_t sdulen, size_t *out_len, int *msg_id) {
	if (sdulen < 7) return NULL;
	*msg_id = sdu[3] | (sdu[4] << 8);
	const uint8_t *p = sdu + 7, *end = sdu + sdulen;
	while (p + 3 <= end) {
		uint8_t t = p[0]; uint16_t l = p[1] | (p[2] << 8); p += 3;
		if (p + l > end) break;
		if (t == 0x02) {                           /* data TLV */
			if (l < 2) return NULL;
			uint16_t plen = p[0] | (p[1] << 8);    /* inner u16 length */
			if (plen > l - 2) plen = l - 2;
			*out_len = plen; return p + 2;
		}
		p += l;
	}
	return NULL;
}

/* ---------------- response parsing ---------------- */
/* SscClientResponse { SscUid uid=1; repeated SscClientResponseBody response=2 } */
/* SscClientResponseBody { fixed32 msg_id=1; fixed64 timestamp=2; bytes msg=3 } */
static void handle_response(const uint8_t *pb, size_t len, const char *want_type,
			    uint64_t *found_lo, uint64_t *found_hi) {
	struct pb s = { pb, pb + len };
	uint64_t uid_lo = 0, uid_hi = 0;
	int field, wt;
	while (pb_read_tag(&s, &field, &wt)) {
		if (field == 1 && wt == 2) {           /* uid */
			size_t n; const uint8_t *d = pb_read_bytes(&s, &n);
			struct pb u = { d, d + n }; int f2, w2;
			while (pb_read_tag(&u, &f2, &w2)) {
				if (f2 == 1) uid_lo = pb_read_fixed64(&u);
				else if (f2 == 2) uid_hi = pb_read_fixed64(&u);
				else pb_skip(&u, w2);
			}
		} else if (field == 2 && wt == 2) {    /* response body */
			size_t n; const uint8_t *d = pb_read_bytes(&s, &n);
			struct pb r = { d, d + n }; int f2, w2;
			uint32_t msg_id = 0; uint64_t ts = 0; const uint8_t *msg = NULL; size_t msglen = 0;
			while (pb_read_tag(&r, &f2, &w2)) {
				if (f2 == 1 && w2 == 5) msg_id = pb_read_fixed32(&r);
				else if (f2 == 2 && w2 == 1) ts = pb_read_fixed64(&r);
				else if (f2 == 3 && w2 == 2) { msg = pb_read_bytes(&r, &msglen); }
				else pb_skip(&r, w2);
			}
			if (msg_id == MSG_RESPONSE_SUID) {
				/* SscSuidResponse { string data_type=1; repeated SscUid uid=2 } */
				struct pb m = { msg, msg + msglen }; int f3, w3;
				char dtype[64] = "";
				while (pb_read_tag(&m, &f3, &w3)) {
					if (f3 == 1 && w3 == 2) { size_t dn; const uint8_t *dd = pb_read_bytes(&m, &dn);
						if (dn > 63) dn = 63; memcpy(dtype, dd, dn); dtype[dn] = 0; }
					else if (f3 == 2 && w3 == 2) { size_t un; const uint8_t *ud = pb_read_bytes(&m, &un);
						struct pb u = { ud, ud + un }; int f4, w4; uint64_t lo = 0, hi = 0;
						while (pb_read_tag(&u, &f4, &w4)) {
							if (f4 == 1) lo = pb_read_fixed64(&u);
							else if (f4 == 2) hi = pb_read_fixed64(&u);
							else pb_skip(&u, w4);
						}
						printf("  SUID for '%s': low=0x%016llx high=0x%016llx\n",
						       dtype, (unsigned long long)lo, (unsigned long long)hi);
						if (want_type && !strcmp(dtype, want_type) && (lo || hi)) {
							*found_lo = lo; *found_hi = hi;
						}
					} else pb_skip(&m, w3);
				}
			} else if (msg_id == MSG_REPORT_MEASUREMENT) {
				/* generic 3-axis: repeated float values=1; int32 accuracy=2 */
				struct pb m = { msg, msg + msglen }; int f3, w3; float v[8]; int nv = 0;
				while (pb_read_tag(&m, &f3, &w3)) {
					if (f3 == 1 && w3 == 5) { uint32_t r = pb_read_fixed32(&m); float f; memcpy(&f, &r, 4); if (nv < 8) v[nv++] = f; }
					else if (f3 == 1 && w3 == 2) { size_t pn; const uint8_t *pd = pb_read_bytes(&m, &pn); /* packed */
						struct pb pk = { pd, pd + pn }; while (pk.p + 4 <= pk.end) { uint32_t r = pb_read_fixed32(&pk); float f; memcpy(&f, &r, 4); if (nv < 8) v[nv++] = f; } }
					else pb_skip(&m, w3);
				}
				printf("  [%s] ts=%llu", want_type ? want_type : "?", (unsigned long long)ts);
				for (int i = 0; i < nv; i++) printf(" %+.4f", v[i]);
				printf("\n");
			} else {
				printf("  (msg_id=%u uid=%016llx%016llx, %zu bytes)\n", msg_id,
				       (unsigned long long)uid_hi, (unsigned long long)uid_lo, msglen);
			}
		} else pb_skip(&s, wt);
	}
	(void)uid_lo; (void)uid_hi;
}


/* ---- feed additions ---- */
#include <fcntl.h>

/* probe QMI framing mode until service accepts (result==0); sets g_mode */
static int probe_mode(int s, struct sockaddr_qrtr *svc) {
	for (g_mode = 0; g_mode <= 4; g_mode++) {
		struct buf in0; b_init(&in0); pb_bytes(&in0, 1, "accel", 5); pb_varfield(&in0, 2, 1);
		struct buf rq0; build_client_request(&rq0, SUID_ABAB, SUID_ABAB, MSG_REQUEST_SUID, in0.p, in0.len);
		uint8_t sd0[2048]; size_t l0 = build_qmi(sd0, 10 + g_mode, rq0.p, rq0.len);
		sendto(s, sd0, l0, 0, (struct sockaddr *)svc, sizeof(*svc));
		free(in0.p); free(rq0.p);
		for (int k = 0; k < 8; k++) {
			uint8_t rx[16384]; struct sockaddr_qrtr from; socklen_t fl = sizeof(from);
			int n = recvfrom(s, rx, sizeof(rx), 0, (struct sockaddr *)&from, &fl);
			if (n <= 0) break;
			if (from.sq_port == QRTR_PORT_CTRL) continue;
			if (rx[0] == 0x02) { int err = -1, res = qmi_result(rx, n, &err); if (res == 0) return 0; break; }
		}
	}
	return -1;
}

/* resolve a data_type to its SUID */
static int resolve_suid(int s, struct sockaddr_qrtr *svc, const char *dtype, uint64_t *lo, uint64_t *hi) {
	struct buf inner; b_init(&inner); pb_bytes(&inner, 1, dtype, strlen(dtype)); pb_varfield(&inner, 2, 1);
	struct buf req; build_client_request(&req, SUID_ABAB, SUID_ABAB, MSG_REQUEST_SUID, inner.p, inner.len);
	uint8_t sdu[2048]; size_t sl = build_qmi(sdu, 1, req.p, req.len);
	sendto(s, sdu, sl, 0, (struct sockaddr *)svc, sizeof(*svc));
	free(inner.p); free(req.p);
	*lo = *hi = 0;
	struct timeval tv = { .tv_sec = 5 }; setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));
	time_t t0 = time(NULL);
	while (time(NULL) - t0 < 5 && !(*lo || *hi)) {
		uint8_t rx[16384]; struct sockaddr_qrtr from; socklen_t fl = sizeof(from);
		int n = recvfrom(s, rx, sizeof(rx), 0, (struct sockaddr *)&from, &fl);
		if (n <= 0) break;
		if (from.sq_port == QRTR_PORT_CTRL) continue;
		size_t plen; int mid; const uint8_t *pl = qmi_indication_payload(rx, n, &plen, &mid);
		if (pl) handle_response(pl, plen, dtype, lo, hi);
	}
	return (*lo || *hi) ? 0 : -1;
}

static void enable_stream(int s, struct sockaddr_qrtr *svc, uint64_t lo, uint64_t hi, float rate) {
	struct buf cfg; b_init(&cfg); uint32_t r; memcpy(&r, &rate, 4); pb_fixed32(&cfg, 1, r);
	struct buf req; build_client_request(&req, lo, hi, MSG_REQUEST_ENABLE_CONT, cfg.p, cfg.len);
	uint8_t sdu[2048]; size_t sl = build_qmi(sdu, 2, req.p, req.len);
	sendto(s, sdu, sl, 0, (struct sockaddr *)svc, sizeof(*svc));
	free(cfg.p); free(req.p);
}

/* parse a report indication: outer uid + the measurement floats of body msg_id 1025 */
static int parse_report(const uint8_t *pb, size_t len, uint64_t *ulo, uint64_t *uhi, float v[3]) {
	struct pb s = { pb, pb + len }; int field, wt; int got = 0;
	*ulo = *uhi = 0;
	while (pb_read_tag(&s, &field, &wt)) {
		if (field == 1 && wt == 2) { size_t n; const uint8_t *d = pb_read_bytes(&s, &n);
			struct pb u = { d, d + n }; int f2, w2;
			while (pb_read_tag(&u, &f2, &w2)) { if (f2==1) *ulo=pb_read_fixed64(&u); else if (f2==2) *uhi=pb_read_fixed64(&u); else pb_skip(&u,w2); }
		} else if (field == 2 && wt == 2) { size_t n; const uint8_t *d = pb_read_bytes(&s, &n);
			struct pb r = { d, d + n }; int f2, w2; uint32_t msg_id = 0; const uint8_t *msg = NULL; size_t ml = 0;
			while (pb_read_tag(&r, &f2, &w2)) {
				if (f2==1&&w2==5) msg_id = pb_read_fixed32(&r);
				else if (f2==3&&w2==2) msg = pb_read_bytes(&r, &ml);
				else pb_skip(&r, w2);
			}
			if (msg_id == MSG_REPORT_MEASUREMENT && msg) {
				struct pb m = { msg, msg + ml }; int f3, w3; int nv = 0;
				while (pb_read_tag(&m, &f3, &w3)) {
					if (f3==1&&w3==5) { uint32_t x=pb_read_fixed32(&m); float f; memcpy(&f,&x,4); if(nv<3) v[nv++]=f; }
					else if (f3==1&&w3==2) { size_t pn; const uint8_t *pd=pb_read_bytes(&m,&pn); struct pb pk={pd,pd+pn}; while(pk.p+4<=pk.end){uint32_t x=pb_read_fixed32(&pk);float f;memcpy(&f,&x,4);if(nv<3)v[nv++]=f;} }
					else pb_skip(&m, w3);
				}
				if (nv >= 3) got = 1;
			}
		} else pb_skip(&s, wt);
	}
	return got;
}

/* Gyro auto bias-calibration (like JoyShock / real gyro drivers):
 * seed the bias over the first second (assume the device is still at startup),
 * then keep refining it via a slow EMA whenever the de-biased rate is small
 * (device roughly still). Subtract the estimate so at rest all axes -> ~0. */
#include <math.h>
static void debias_gyro(float v[3]) {
	static double bias[3] = {0,0,0};
	static double seed_sum[3] = {0,0,0};
	static int seed_count = 0;
	const int SEED_N = 100;      /* 1s @ 100Hz */
	const double STILL = 0.09;   /* rad/s (~5 deg/s): below -> still */
	const double ALPHA = 0.002;  /* bias EMA when still (~5s tau) */
	int i;
	if (seed_count < SEED_N) {
		for (i = 0; i < 3; i++) seed_sum[i] += v[i];
		seed_count++;
		if (seed_count == SEED_N) for (i = 0; i < 3; i++) bias[i] = seed_sum[i] / SEED_N;
		for (i = 0; i < 3; i++) v[i] -= seed_sum[i] / seed_count; /* running mean while seeding */
		return;
	}
	double dx = v[0]-bias[0], dy = v[1]-bias[1], dz = v[2]-bias[2];
	if (sqrt(dx*dx + dy*dy + dz*dz) < STILL)
		for (i = 0; i < 3; i++) bias[i] += ALPHA * (v[i] - bias[i]);
	for (i = 0; i < 3; i++) v[i] -= bias[i];
}

int main(int argc, char **argv) {
	float rate = argc > 1 ? atof(argv[1]) : 100.0f;
	int fd = open("/dev/sns_iio_feed", O_WRONLY);
	if (fd < 0) { perror("open /dev/sns_iio_feed"); return 1; }

	int s = qrtr_open();
	struct sockaddr_qrtr svc;
	if (qrtr_lookup(s, SSC_SVC_ID, &svc) < 0) { fprintf(stderr, "svc 400 not found\n"); return 1; }
	if (probe_mode(s, &svc) < 0) { fprintf(stderr, "no QMI framing accepted\n"); return 1; }
	fprintf(stderr, "snsfeed: svc @ %u:%u framing mode %d\n", svc.sq_node, svc.sq_port, g_mode);

	uint64_t alo, ahi, glo, ghi;
	if (resolve_suid(s, &svc, "accel", &alo, &ahi) < 0) { fprintf(stderr, "no accel SUID (daemon up?)\n"); return 2; }
	if (resolve_suid(s, &svc, "gyro", &glo, &ghi) < 0) { fprintf(stderr, "no gyro SUID\n"); return 2; }
	fprintf(stderr, "snsfeed: accel=%016llx:%016llx gyro=%016llx:%016llx\n",
		(unsigned long long)ahi,(unsigned long long)alo,(unsigned long long)ghi,(unsigned long long)glo);

	enable_stream(s, &svc, alo, ahi, rate);
	enable_stream(s, &svc, glo, ghi, rate);
	fprintf(stderr, "snsfeed: streaming accel+gyro @ %.0f Hz -> /dev/sns_iio_feed\n", rate);

	s32vals cache = {0};
	struct timeval tv = { .tv_sec = 2 }; setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));
	for (;;) {
		uint8_t rx[16384]; struct sockaddr_qrtr from; socklen_t fl = sizeof(from);
		int n = recvfrom(s, rx, sizeof(rx), 0, (struct sockaddr *)&from, &fl);
		if (n <= 0) continue;
		if (from.sq_port == QRTR_PORT_CTRL) continue;
		size_t plen; int mid; const uint8_t *pl = qmi_indication_payload(rx, n, &plen, &mid);
		if (!pl) continue;
		uint64_t ulo, uhi; float v[3];
		if (!parse_report(pl, plen, &ulo, &uhi, v)) continue;
		if (ulo == alo && uhi == ahi) { cache.v[0]=(s32)(v[0]*1e6f); cache.v[1]=(s32)(v[1]*1e6f); cache.v[2]=(s32)(v[2]*1e6f); }
		else if (ulo == glo && uhi == ghi) { debias_gyro(v); cache.v[3]=(s32)(v[0]*1e6f); cache.v[4]=(s32)(v[1]*1e6f); cache.v[5]=(s32)(v[2]*1e6f); }
		else continue;
		if (write(fd, cache.v, sizeof(cache.v)) != sizeof(cache.v)) { /* ignore */ }
	}
	return 0;
}
