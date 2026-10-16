#!/usr/bin/env bash
# Remove a camada de economia de tokens de ~/.claude, mexendo só no que ela pôs.
set -euo pipefail
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
command -v jq >/dev/null || { echo "Falta o jq. Instale com: sudo apt install jq"; exit 1; }

# CLAUDE.md: tira só o bloco da camada (recusa se os marcadores estiverem incompletos: BUG-004)
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
  n_ini=$(grep -cxF '<!-- camada-economia-tokens:inicio -->' "$CLAUDE_DIR/CLAUDE.md" || true)
  n_fim=$(grep -cxF '<!-- camada-economia-tokens:fim -->' "$CLAUDE_DIR/CLAUDE.md" || true)
  if [ "$n_ini" != "$n_fim" ]; then
    echo "Erro: $CLAUDE_DIR/CLAUDE.md tem marcadores da camada incompletos ($n_ini início, $n_fim fim). Corrija à mão; nada foi removido." >&2
    exit 1
  fi
  awk '$0=="<!-- camada-economia-tokens:inicio -->"{p=1} !p{print} $0=="<!-- camada-economia-tokens:fim -->"{p=0}' \
    "$CLAUDE_DIR/CLAUDE.md" > "$CLAUDE_DIR/CLAUDE.md.novo" && mv "$CLAUDE_DIR/CLAUDE.md.novo" "$CLAUDE_DIR/CLAUDE.md"
fi

# settings.json: tira só as chaves com os valores da camada
if [ -f "$CLAUDE_DIR/settings.json" ]; then
  jq '
    (if .model == "sonnet" then del(.model) else . end)
    | (if .effortLevel == "medium" then del(.effortLevel) else . end)
    | (if .env.CLAUDE_CODE_SUBAGENT_MODEL == "haiku" then del(.env.CLAUDE_CODE_SUBAGENT_MODEL) else . end)
    | (if (.env // {}) == {} then del(.env) else . end)
    | (if .statusLine.command == "~/.claude/economia/statusline.sh" then del(.statusLine) else . end)
    | (if .hooks.UserPromptSubmit then .hooks.UserPromptSubmit |= map(select((.hooks // []) | any((.command // "") | test("economia/modo\\.sh")) | not)) else . end)
    | (if .hooks.UserPromptSubmit == [] then del(.hooks.UserPromptSubmit) else . end)
    | (if (.hooks // {}) == {} then del(.hooks) else . end)
  ' "$CLAUDE_DIR/settings.json" > "$CLAUDE_DIR/settings.json.novo" && mv "$CLAUDE_DIR/settings.json.novo" "$CLAUDE_DIR/settings.json"
fi

# subagentes: só apaga se for igual ao da camada; um seu de mesmo nome fica (BUG-003)
for a in "$AQUI"/claude/agents/*.md; do
  destino="$CLAUDE_DIR/agents/$(basename "$a")"
  if cmp -s "$a" "$destino"; then rm -f "$destino"; elif [ -f "$destino" ]; then echo "Mantido o seu $(basename "$a")"; fi
done
rm -f "$CLAUDE_DIR/economia/statusline.sh" "$CLAUDE_DIR/economia/modo.sh" "$CLAUDE_DIR/economia/uso.json"
echo "Camada removida. Backups e limites.conf continuam em $CLAUDE_DIR/economia."
