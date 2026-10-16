#!/usr/bin/env bash
# Decide o modo de economia (VERDE, AMARELO, VERMELHO) pelo uso do plano e,
# como hook UserPromptSubmit, anexa uma linha de contexto a cada mensagem.
#   modo.sh            -> saída JSON para o hook
#   modo.sh --so-modo  -> só o nome do modo (usado pela barra de status)
# Limites ajustáveis em ~/.claude/economia/limites.conf
set -u
export LC_ALL=C   # números com ponto decimal, mesmo em pt_BR (BUG-001)
dir="${HOME}/.claude/economia"
AMARELO=50
VERMELHO=80
CONTEXTO_ALTO=60
MAX_IDADE=900   # segundos; uso mais velho que isso é tratado como desconhecido
# shellcheck source=/dev/null
[ -f "$dir/limites.conf" ] && . "$dir/limites.conf"

# no modo hook, o Claude Code manda JSON no stdin; não precisamos dele
if [ "${1:-}" != "--so-modo" ] && [ ! -t 0 ]; then cat >/dev/null; fi

h5=""; sem=""; ctx=0
if [ -f "$dir/uso.json" ]; then
  idade=$(( $(date +%s) - $(jq -r '.atualizado // 0' "$dir/uso.json" 2>/dev/null || echo 0) ))
  if [ "$idade" -le "$MAX_IDADE" ]; then
    h5=$(jq -r '.cinco_horas // empty' "$dir/uso.json" 2>/dev/null)
    sem=$(jq -r '.semanal // empty' "$dir/uso.json" 2>/dev/null)
  fi
  ctx=$(jq -r '.contexto // 0' "$dir/uso.json" 2>/dev/null)
fi

maior=$(printf '%s\n%s\n' "${h5:-0}" "${sem:-0}" | sort -g | tail -1)
maior=${maior%.*}
if   [ -z "$h5$sem" ];              then modo="VERDE"; base="uso do plano desconhecido"
elif [ "$maior" -ge "$VERMELHO" ];  then modo="VERMELHO"; base="uso do plano em ${maior}%"
elif [ "$maior" -ge "$AMARELO" ];   then modo="AMARELO"; base="uso do plano em ${maior}%"
else                                     modo="VERDE"; base="uso do plano em ${maior}%"
fi

if [ "${1:-}" = "--so-modo" ]; then echo "$modo"; exit 0; fi

texto="Modo de economia: $modo ($base"
[ "${ctx%.*}" -ge "$CONTEXTO_ALTO" ] 2>/dev/null && texto="$texto; contexto da conversa em ${ctx%.*}%, considerar sugerir /clear ou /compact"
texto="$texto)."
jq -n --arg t "$texto" '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: $t}}'
