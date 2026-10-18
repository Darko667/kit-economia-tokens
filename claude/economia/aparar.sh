#!/usr/bin/env bash
# Hook PostToolUse (Bash): encurta saídas longas antes de chegarem ao Claude.
# Mantém o começo, as linhas de erro/aviso e o fim; a íntegra fica num arquivo que o Claude pode ler.
# Limites em ~/.claude/economia/limites.conf (APARAR_LINHAS, APARAR_CABECA, APARAR_CAUDA, APARAR_ERROS).
set -u
export LC_ALL=C.UTF-8 2>/dev/null || export LC_ALL=C
dir="${HOME}/.claude/economia"
APARAR_LINHAS=120; APARAR_CABECA=40; APARAR_CAUDA=30; APARAR_ERROS=40
# shellcheck source=/dev/null
[ -f "$dir/limites.conf" ] && . "$dir/limites.conf"
[ "$APARAR_LINHAS" -gt 0 ] 2>/dev/null || exit 0   # APARAR_LINHAS=0 desliga

entrada=$(cat)
[ "$(printf '%s' "$entrada" | jq -r '.tool_name // ""' 2>/dev/null)" = "Bash" ] || exit 0
saida=$(printf '%s' "$entrada" | jq -r '.tool_response.stdout // empty' 2>/dev/null) || exit 0
n=$(printf '%s\n' "$saida" | wc -l)
[ "$n" -gt "$APARAR_LINHAS" ] || exit 0

mkdir -p "$dir/saidas"
find "$dir/saidas" -type f -mmin +1440 -delete 2>/dev/null   # guarda só o último dia
arq="$dir/saidas/$(date +%Y%m%d-%H%M%S)-$$.txt"
printf '%s\n' "$saida" > "$arq"

meio_ini=$((APARAR_CABECA + 1)); meio_fim=$((n - APARAR_CAUDA))
curta=$(
  head -n "$APARAR_CABECA" "$arq"
  sed -n "${meio_ini},${meio_fim}p" "$arq" \
    | grep -i -E 'error|erro|fail|falh|warn|aviso|exception|traceback|panic|denied|not found|✗' | head -n "$APARAR_ERROS"
  echo "[camada: $((meio_fim - meio_ini + 1)) linhas do meio omitidas (as de erro/aviso ficaram acima); saída completa: $arq]"
  tail -n "$APARAR_CAUDA" "$arq"
)

printf '%s' "$entrada" | jq --arg s "$curta" '{hookSpecificOutput: {hookEventName: "PostToolUse",
  updatedToolOutput: (.tool_response + {stdout: $s})}}'
