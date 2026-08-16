#!/usr/bin/env bash
set -euo pipefail
# usage: PROJECT=... DEVICE=... ARCH=... tools/list_deps.sh toolchain alsa-lib llvm:host

declare -A SEEN
QUEUE=()
for a in "$@"; do QUEUE+=("${a}|walk"); done
WALK_DIRS=()
LEAF_DIRS=()
WATCH_PATHS=()

while [ ${#QUEUE[@]} -gt 0 ]; do
  entry="${QUEUE[0]}"
  QUEUE=("${QUEUE[@]:1}")
  pkg="${entry%|*}"
  mode="${entry#*|}"

  base="${pkg%%:*}"
  stage="target"
  case "$pkg" in
    *:host) stage="host" ;;
    *:init) stage="init" ;;
    *:bootstrap) stage="bootstrap" ;;
  esac

  key="${base}:${stage}"
  [ -n "${SEEN[$key]:-}" ] && continue
  SEEN[$key]=1

  info=$(tools/pkginfo "${base}" 2>/dev/null) || continue

  dir=$(echo "$info" | grep '^PKG_DIR=' | cut -d'"' -f2)
  if [ -n "$dir" ]; then
    if [ "$mode" = "leaf" ]; then
      LEAF_DIRS+=("$dir")
    else
      WALK_DIRS+=("$dir")
    fi
  fi

  need_unpack=$(echo "$info" | grep '^PKG_NEED_UNPACK=' | cut -d'"' -f2)
  for p in $need_unpack; do
    [ -d "$p" ] && WATCH_PATHS+=("$p")
  done

  [ "$mode" = "leaf" ] && continue

  case "$stage" in
    host)      deps=$(echo "$info" | grep '^PKG_DEPENDS_HOST=' | cut -d'"' -f2) ;;
    init)      deps=$(echo "$info" | grep '^PKG_DEPENDS_INIT=' | cut -d'"' -f2) ;;
    bootstrap) deps=$(echo "$info" | grep '^PKG_DEPENDS_BOOTSTRAP=' | cut -d'"' -f2) ;;
    *)         deps=$(echo "$info" | grep '^PKG_DEPENDS_TARGET=' | cut -d'"' -f2) ;;
  esac
  unpack_deps=$(echo "$info" | grep '^PKG_DEPENDS_UNPACK=' | cut -d'"' -f2)

  for d in $deps; do
    [ "$d" = "$base" ] && continue
    QUEUE+=("${d}|walk")
  done
  for d in $unpack_deps; do
    [ "$d" = "$base" ] && continue
    QUEUE+=("${d}|leaf")
  done
done

WALK_NAMES=$(printf '%s\n' "${WALK_DIRS[@]}" | xargs -n1 basename | sort -u)
LEAF_NAMES=$(printf '%s\n' "${LEAF_DIRS[@]}" | xargs -n1 basename | sort -u)
ALL_NAMES=$(printf '%s\n%s\n' "$WALK_NAMES" "$LEAF_NAMES" | sort -u)
WATCH_UNIQUE=$(printf '%s\n' "${WATCH_PATHS[@]}" | sort -u)

{
  echo "# Built packages (own BUILD step): $(echo "$WALK_NAMES" | grep -c .)"
  echo "$WALK_NAMES"
  echo
  echo "# Unpack-only packages (PKG_DEPENDS_UNPACK, no own build step): $(echo "$LEAF_NAMES" | grep -c .)"
  echo "$LEAF_NAMES"
  echo
  echo "# Total resolved packages: $(echo "$ALL_NAMES" | grep -c .)"
  echo
  echo "# Watch paths (PKG_NEED_UNPACK, project/device overlays etc.): $(echo "$WATCH_UNIQUE" | grep -c .)"
  echo "$WATCH_UNIQUE"
} >&2

# stdout stays script-consumable: dirs to hash for package.mk/patch content,
# then a marker, then watch-paths to hash as raw file content
printf '%s\n' "${WALK_DIRS[@]}" "${LEAF_DIRS[@]}" | sort -u
echo '---WATCH---'
printf '%s\n' "$WATCH_UNIQUE"
