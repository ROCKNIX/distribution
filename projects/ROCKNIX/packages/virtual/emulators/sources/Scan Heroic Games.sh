#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

source /etc/profile

HEROIC_BASE="/storage/.local/share/heroic-arm64"
HEROIC_BIN=""
ROMS_DIR="/storage/roms/heroic"
LEGENDARY_INSTALLED="/storage/.config/heroic/legendaryConfig/legendary/installed.json"
GOG_INSTALLED="/storage/.config/heroic/gog_store/installed.json"
NILE_INSTALLED="/storage/.config/heroic/nile_config/installed.json"

resolve_heroic_bin() {
  HEROIC_BIN=""
  for candidate in "${HEROIC_BASE}"/Heroic*/heroic "${HEROIC_BASE}"/heroic; do
    [ -x "${candidate}" ] || continue
    HEROIC_BIN="${candidate}"
    return 0
  done
  return 1
}

if ! resolve_heroic_bin; then
  echo "Heroic is not installed. Run 'Install Heroic Games Launcher.sh' first." >&2
  exit 1
fi

mkdir -p "${ROMS_DIR}"

for launcher in "${ROMS_DIR}"/*.sh; do
  [ -f "${launcher}" ] || continue
  case "$(basename "${launcher}")" in
    "Heroic Games Launcher (Authenticate).sh"|"Heroic Games Launcher.sh"|"Heroic Games Launcher (Gamescope).sh")
      ;;
    *)
      rm -f "${launcher}"
      ;;
  esac
done

sanitize_filename() {
  echo "$1" | sed 's#[/\\:*?"<>|]#_#g'
}

heroic_library_title_map_json() {
  local path="$1"
  [ -r "${path}" ] || {
    echo '{}'
    return 0
  }
  jq -c '
    (.games // [])
    | map(select(.app_name != null and (.app_name | tostring | length) > 0))
    | map({(.app_name | tostring): (.title // .name // "")})
    | add // {}
    | with_entries(select((.value | type == "string") and (.value | length) > 0))
  ' "${path}" 2>/dev/null || echo '{}'
}

create_launcher() {
  local title="$1"
  local uri="$2"
  local launcher_name
  local launcher_path

  launcher_name="$(sanitize_filename "${title}")"
  launcher_path="${ROMS_DIR}/${launcher_name}.sh"

  cat >"${launcher_path}" <<EOF
#!/bin/bash
source /etc/profile
for HEROIC_LAUNCHER_DIR in /storage/.config/heroic-launchers /storage/.config/modules /usr/config/modules; do
  H="\${HEROIC_LAUNCHER_DIR}/Start Heroic Play.sh"
  [ -x "\${H}" ] || continue
  exec "\${H}" --no-gui $(printf '%q' "${uri}")
done
H="/usr/bin/start_heroic_play.sh"
[ -x "\${H}" ] && exec "\${H}" --no-gui $(printf '%q' "${uri}")
echo "Heroic: start_heroic_play.sh not found under /storage/.config/heroic-launchers, /storage/.config/modules, /usr/config/modules, or /usr/bin." >&2
exit 127
EOF
  chmod 0755 "${launcher_path}"
}

if [ -f "${LEGENDARY_INSTALLED}" ]; then
  jq -r '
    to_entries[] |
    select(.value.is_installed == true or .value.install_path != null) |
    [(.value.title // .key), ("heroic://launch?appName=" + (.key | @uri) + "&runner=legendary")] |
    @tsv
  ' "${LEGENDARY_INSTALLED}" | while IFS=$'\t' read -r title uri; do
    [ -n "${title}" ] || continue
    create_launcher "${title}" "${uri}"
  done
fi

GOG_LIB_CACHE="/storage/.config/heroic/store_cache/gog_library.json"
GOG_TITLE_LOOKUP="$(heroic_library_title_map_json "${GOG_LIB_CACHE}")"

if [ -f "${GOG_INSTALLED}" ]; then
  jq -r --argjson lookup "${GOG_TITLE_LOOKUP}" '
    (
      if type == "array" then .[]
      elif type == "object" and (.installed | type == "array") then .installed[]
      else to_entries[] | .value | if type == "array" then .[] else . end
      end
    ) |
    . as $g |
    ($g.appName // $g.app_name // $g.id // $g.gameId // empty) as $id |
    select($id != null and $id != "") |
    [
      (
        if (($g.title // "") | length) > 0 then $g.title
        elif (($g.name // "") | length) > 0 then $g.name
        elif (($g.gameTitle // "") | length) > 0 then $g.gameTitle
        elif (($lookup[($id | tostring)] // "") | length) > 0 then $lookup[($id | tostring)]
        elif (($g.install_path // "") | length) > 0 then ($g.install_path | split("/") | map(select(length > 0)) | .[-1])
        else ($id | tostring)
        end
      ),
      ("heroic://launch?appName=" + ($id | tostring | @uri) + "&runner=gog")
    ] |
    @tsv
  ' "${GOG_INSTALLED}" | while IFS=$'\t' read -r title uri; do
    [ -n "${title}" ] || continue
    create_launcher "${title}" "${uri}"
  done
fi

NILE_LIB_CACHE="/storage/.config/heroic/store_cache/nile_library.json"
NILE_TITLE_LOOKUP="$(heroic_library_title_map_json "${NILE_LIB_CACHE}")"

if [ -f "${NILE_INSTALLED}" ]; then
  jq -r --argjson lookup "${NILE_TITLE_LOOKUP}" '
    (
      if type == "array" then .[]
      elif type == "object" and (.installed | type == "array") then .installed[]
      else to_entries[] | .value | if type == "array" then .[] else . end
      end
    ) |
    . as $g |
    ($g.app_name // $g.appName // $g.id // empty) as $id |
    select($id != null and $id != "") |
    [
      (
        if (($g.title // "") | length) > 0 then $g.title
        elif (($g.name // "") | length) > 0 then $g.name
        elif (($lookup[($id | tostring)] // "") | length) > 0 then $lookup[($id | tostring)]
        elif (($g.install_path // "") | length) > 0 then ($g.install_path | split("/") | map(select(length > 0)) | .[-1])
        else ($id | tostring)
        end
      ),
      ("heroic://launch?appName=" + ($id | tostring | @uri) + "&runner=nile")
    ] |
    @tsv
  ' "${NILE_INSTALLED}" | while IFS=$'\t' read -r title uri; do
    [ -n "${title}" ] || continue
    create_launcher "${title}" "${uri}"
  done
fi

launcher_count="$(find "${ROMS_DIR}" -maxdepth 1 -name '*.sh' -type f 2>/dev/null | wc -l)"
launcher_count="${launcher_count//[[:space:]]/}"
echo ""
echo "Heroic scan completed successfully. ${launcher_count} launcher script(s) in ${ROMS_DIR}."
echo "You can launch them from EmulationStation in the Heroic section."
if [ -t 0 ]; then
  echo "Press any key to continue (auto-closes in 5 seconds)..."
  IFS= read -r -n 1 -s -t 5 _ || true
else
  sleep 5
fi
