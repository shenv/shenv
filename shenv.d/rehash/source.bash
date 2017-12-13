PROTOTYPE_SOURCE_SHIM_PATH="${SHIM_PATH}/.shenv-source-shim"

shims=()
shopt -s nullglob
for shim in $(cat "${BASH_SOURCE%/*}/source.d/"*".list" | sort | uniq | sed -e 's/#.*$//' | sed -e '/^[[:space:]]*$/d'); do
  if [ -n "${shim##*/}" ]; then
    shims[${#shims[*]}]="${shim})return 0;;"
  fi
done
shopt -u nullglob
eval "source_shim(){ case \"\${1##*/}\" in ${shims[@]} *)return 1;;esac;}"

cat > "${PROTOTYPE_SOURCE_SHIM_PATH}" <<SH
[ -n "\$SHENV_DEBUG" ] && set -x
export SHENV_ROOT="${SHENV_ROOT}"
program="\$("$(command -v shenv)" which "\${BASH_SOURCE##*/}")"
if [ -e "\${program}" ]; then
  . "\${program}" "\$@"
fi
SH
chmod +x "${PROTOTYPE_SOURCE_SHIM_PATH}"

shopt -s nullglob
for shim in "${SHIM_PATH}/"*; do
  if source_shim "${shim}"; then
    cp "${PROTOTYPE_SOURCE_SHIM_PATH}" "${shim}"
  fi
done
shopt -u nullglob

rm -f "${PROTOTYPE_SOURCE_SHIM_PATH}"
