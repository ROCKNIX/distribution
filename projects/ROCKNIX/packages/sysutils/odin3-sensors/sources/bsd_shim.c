#include <string.h>
#include <stddef.h>
size_t strlcpy(char *dst, const char *src, size_t sz){size_t l=strlen(src);if(sz){size_t n=l>=sz?sz-1:l;memcpy(dst,src,n);dst[n]=0;}return l;}
size_t strlcat(char *dst, const char *src, size_t sz){size_t dl=strnlen(dst,sz),sl=strlen(src);if(dl==sz)return sz+sl;size_t n=sl>=sz-dl?sz-dl-1:sl;memcpy(dst+dl,src,n);dst[dl+n]=0;return dl+sl;}
