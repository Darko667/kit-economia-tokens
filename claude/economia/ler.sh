#!/usr/bin/env bash
# Hook PreToolUse (Read): limita a leitura de arquivo de código longo quando o Claude não pediu trecho.
# Não bloqueia nada: só acrescenta "limit" e avisa como ler o resto. Limites em limites.conf
# (LER_MIN_LINHAS: a partir de quantas linhas age; LER_LIMITE: quantas linhas devolver; 0 desliga).
set -u
export LC_ALL=C
dir="${HOME}/.claude/economia"
LER_MIN_LINHAS=600; LER_LIMITE=400
# shellcheck source=/dev/null
[ -f "$dir/limites.conf" ] && . "$dir/limites.conf"
[ "$LER_LIMITE" -gt 0 ] 2>/dev/null || exit 0

entrada=$(cat)
[ "$(printf '%s' "$entrada" | jq -r '.tool_name // ""' 2>/dev/null)" = "Read" ] || exit 0
# já pediu trecho, ou pediu o arquivo inteiro de propósito: não mexe
printf '%s' "$entrada" | jq -e '.tool_input | (.offset != null or .limit != null or .allow_large == true)' >/dev/null 2>&1 && exit 0
arq=$(printf '%s' "$entrada" | jq -r '.tool_input.file_path // ""')
case "${arq##*.}" in
  py|ts|tsx|js|jsx|mjs|cjs|go|rs|java|kt|rb|php|cs|c|h|cpp|hpp|swift|scala|sh|bash|lua|dart|vue|svelte|sql) ;;
  *) exit 0 ;;
esac
[ -f "$arq" ] || exit 0
n=$(wc -l < "$arq")
[ "$n" -ge "$LER_MIN_LINHAS" ] || exit 0

aviso="Camada: $arq tem $n linhas; foram lidas só as $LER_LIMITE primeiras. Para o resto, use Grep para achar a linha e Read com offset/limit."
printf '%s' "$entrada" | jq --argjson l "$LER_LIMITE" --arg a "$aviso" '{hookSpecificOutput: {hookEventName: "PreToolUse",
  updatedInput: (.tool_input + {limit: $l}), additionalContext: $a}}'
