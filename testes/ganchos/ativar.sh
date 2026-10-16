#!/usr/bin/env bash
# Liga (ou, com --desligar, desliga) o hook que roda a suíte automaticamente no Claude Code.
# Mexe só na entrada deste hook em ~/.claude/settings.json; o resto fica como está.
set -euo pipefail
GANCHO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/ao-parar.sh"
S="${HOME}/.claude/settings.json"
command -v jq >/dev/null || { echo "Falta o jq. Instale com: sudo apt install jq"; exit 1; }
mkdir -p "$(dirname "$S")"; [ -f "$S" ] || echo '{}' > "$S"
jq empty "$S" || { echo "Erro: $S não é JSON válido; nada foi alterado." >&2; exit 1; }
cp "$S" "$S.antes-gancho-testes"

# o comando vai entre aspas: o Claude Code roda pelo shell e o caminho pode ter espaço (BUG-007)
CMD="\"$GANCHO\""
# reconhece o nosso pelo caminho completo, com ou sem aspas: outro projeto tem o próprio gancho (BUG-006)
sem_o_nosso='((.hooks.Stop // []) | map(select((.hooks // []) | any((.command // "") as $x | $x == $c or $x == $p) | not)))'
if [ "${1:-}" = "--desligar" ]; then
  jq --arg c "$CMD" --arg p "$GANCHO" "$sem_o_nosso as \$o | if \$o == [] then del(.hooks.Stop) else .hooks.Stop = \$o end | if (.hooks // {}) == {} then del(.hooks) else . end" "$S" > "$S.novo"
  echo "Hook de testes desligado."
else
  jq --arg c "$CMD" --arg p "$GANCHO" "$sem_o_nosso as \$o | .hooks.Stop = (\$o + [{hooks: [{type: \"command\", command: \$c, timeout: 180}]}])" "$S" > "$S.novo"
  echo "Hook de testes ligado: $GANCHO"
  echo "Vale a partir da próxima sessão do Claude Code (ou abra /hooks para recarregar)."
fi
mv "$S.novo" "$S"
