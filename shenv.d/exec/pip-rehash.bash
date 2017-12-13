SHENV_PIP_REHASH_ROOT="${BASH_SOURCE[0]%/*}/pip-rehash"
SHENV_REHASH_COMMAND="${SHENV_COMMAND##*/}"

# Remove any version information, from e.g. "pip2" or "pip3.4".
if [[ $SHENV_REHASH_COMMAND =~ ^(pip|easy_install)[23](\.\d)?$ ]]; then
  SHENV_REHASH_COMMAND="${BASH_REMATCH[1]}"
fi

if [ -x "${SHENV_PIP_REHASH_ROOT}/${SHENV_REHASH_COMMAND}" ]; then
  SHENV_COMMAND_PATH="${SHENV_PIP_REHASH_ROOT}/${SHENV_REHASH_COMMAND##*/}"
  SHENV_BIN_PATH="${SHENV_PIP_REHASH_ROOT}"
  export SHENV_REHASH_REAL_COMMAND="${SHENV_COMMAND##*/}"
fi
