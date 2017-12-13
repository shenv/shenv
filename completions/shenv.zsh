if [[ ! -o interactive ]]; then
    return
fi

compctl -K _shenv shenv

_shenv() {
  local words completions
  read -cA words

  if [ "${#words}" -eq 2 ]; then
    completions="$(shenv commands)"
  else
    completions="$(shenv completions ${words[2,-2]})"
  fi

  reply=(${(ps:\n:)completions})
}
