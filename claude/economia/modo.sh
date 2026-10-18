#!/usr/bin/env bash
# Decide o modo de economia (VERDE, AMARELO, VERMELHO) pelo uso do plano e,
# como hook UserPromptSubmit, anexa uma linha de contexto quando o modo muda.
#   modo.sh            -> saída JSON para o hook
#   modo.sh --so-modo  -> só o nome do modo (usado pela barra de status)
#   modo.sh --esquecer -> hook SessionStart (compact|clear): volta a falar na próxima mensagem
# Limites ajustáveis em ~/.claude/economia/limites.conf
set -u
export LC_ALL=C   # números com ponto decimal, mesmo em pt_BR (BUG-001)
dir="${HOME}/.claude/economia"
AMARELO=50
VERMELHO=80
CONTEXTO_ALTO=60
CONTEXTO_ALTO_TOKENS=120000   # contexto em tokens a partir do qual sugerir /clear (janela de 1M torna o % enganoso)
MODO_SEMPRE=0                 # 1 = repetir a linha em toda mensagem; 0 = só quando o modo muda
MAX_IDADE=900   # segundos; uso mais velho que isso é tratado como desconhecido
# shellcheck source=/dev/null
[ -f "$dir/limites.conf" ] && . "$dir/limites.conf"

# no modo hook, o Claude Code manda JSON no stdin; usamos só o session_id
sessao=""
if [ "${1:-}" != "--so-modo" ] && [ ! -t 0 ]; then
  sessao=$(jq -r '.session_id // ""' 2>/dev/null | tr -cd 'A-Za-z0-9_-')
fi
# depois de compactar ou limpar, a linha antiga do modo saiu do contexto: esquece o estado da sessão
if [ "${1:-}" = "--esquecer" ]; then
  [ -n "$sessao" ] && rm -f "$dir/sessoes/$sessao"
  exit 0
fi

h5=""; sem=""; ctx=0; tokens=""
if [ -f "$dir/uso.json" ]; then
  idade=$(( $(date +%s) - $(jq -r '.atualizado // 0' "$dir/uso.json" 2>/dev/null || echo 0) ))
  if [ "$idade" -le "$MAX_IDADE" ]; then
    h5=$(jq -r '.cinco_horas // empty' "$dir/uso.json" 2>/dev/null)
    sem=$(jq -r '.semanal // empty' "$dir/uso.json" 2>/dev/null)
  fi
  ctx=$(jq -r '.contexto // 0' "$dir/uso.json" 2>/dev/null)
  tokens=$(jq -r '.tokens // empty' "$dir/uso.json" 2>/dev/null)
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
alto=0
if [ -n "$tokens" ]; then
  [ "${tokens%.*}" -ge "$CONTEXTO_ALTO_TOKENS" ] 2>/dev/null && alto=1 \
    && texto="$texto; contexto da conversa em $(( ${tokens%.*} / 1000 )) mil tokens, considerar sugerir /clear ou /compact"
else
  [ "${ctx%.*}" -ge "$CONTEXTO_ALTO" ] 2>/dev/null && alto=1 \
    && texto="$texto; contexto da conversa em ${ctx%.*}%, considerar sugerir /clear ou /compact"
fi
texto="$texto)."

# só fala quando o modo (ou o aviso de contexto) muda nesta sessão: cada linha fica no histórico
if [ "$MODO_SEMPRE" != 1 ] && [ -n "$sessao" ]; then
  mkdir -p "$dir/sessoes"
  find "$dir/sessoes" -type f -mtime +7 -delete 2>/dev/null
  estado="$modo $alto"
  [ "$(cat "$dir/sessoes/$sessao" 2>/dev/null)" = "$estado" ] && exit 0
  printf '%s\n' "$estado" > "$dir/sessoes/$sessao"
fi
jq -n --arg t "$texto" '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: $t}}'
