_shenv() {
  COMPREPLY=()
  local word="${COMP_WORDS[COMP_CWORD]}"

  if (( $COMP_CWORD == 1 )); then
    COMPREPLY=( $(compgen -W "$(shenv commands)" -- "$word") )
  else
    local words=("${COMP_WORDS[@]}")
    unset "words[0]"
    unset "words[COMP_CWORD]"
    local completions=$(shenv completions "${words[@]}")
    COMPREPLY=( $(compgen -W "$completions" -- "$word") )
  fi
}

complete -F _shenv shenv
