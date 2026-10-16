#!/usr/bin/env bash
# Barra de status da camada de economia de tokens.
# Mostra modelo, contexto usado, uso da janela de 5 h e semanal, e grava o uso
# em ~/.claude/economia/uso.json para o hook modo.sh decidir o modo de economia.
set -u
export LC_ALL=C   # números com ponto decimal, mesmo em pt_BR (BUG-001)
entrada=$(cat)
dir="${HOME}/.claude/economia"
mkdir -p "$dir"

j() { printf '%s' "$entrada" | jq -r "$1" 2>/dev/null; }

modelo=$(j '.model.display_name // "?"')
ctx=$(j '.context_window.used_percentage // 0 | floor')
h5=$(j '.rate_limits.five_hour.used_percentage // empty')
sem=$(j '.rate_limits.seven_day.used_percentage // empty')
custo=$(j '.cost.total_cost_usd // 0')

# grava o uso para o hook (só quando o plano informa os limites)
if [ -n "$h5" ] || [ -n "$sem" ]; then
  printf '{"cinco_horas": %s, "semanal": %s, "contexto": %s, "atualizado": %s}\n' \
    "${h5:-null}" "${sem:-null}" "${ctx:-0}" "$(date +%s)" > "$dir/uso.json.tmp" \
    && mv "$dir/uso.json.tmp" "$dir/uso.json"
fi

modo=$("$dir/modo.sh" --so-modo 2>/dev/null || echo "?")

linha="[$modelo] ctx ${ctx}%"
[ -n "$h5" ] && linha="$linha · 5h $(printf '%.0f' "$h5")%"
[ -n "$sem" ] && linha="$linha · semana $(printf '%.0f' "$sem")%"
[ -z "$h5" ] && [ -z "$sem" ] && linha="$linha · \$$(printf '%.2f' "$custo")"
printf '%s · modo %s\n' "$linha" "$modo"
