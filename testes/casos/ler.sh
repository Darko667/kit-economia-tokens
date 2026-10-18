# Testes do hook ler.sh (PreToolUse do Read: limita leitura de código longo)

ler() { "$RAIZ/claude/economia/ler.sh"; }
arquivo() { seq 1 "$2" > "$HOME/$1"; echo "$HOME/$1"; }   # arquivo <nome> <linhas>
pedido() { jq -n --arg f "$1" "{tool_name:\"Read\",tool_input:({file_path:\$f} + ${2:-{\}})}"; }

teste_codigo_longo_ganha_limit() {
  r=$(pedido "$(arquivo grande.py 2000)" | ler)
  igual "$(printf '%s' "$r" | jq -r '.hookSpecificOutput.updatedInput.limit')" "400"
  igual "$(printf '%s' "$r" | jq -r '.hookSpecificOutput.updatedInput.file_path')" "$HOME/grande.py"
  contem "$(printf '%s' "$r" | jq -r '.hookSpecificOutput.additionalContext')" "2000 linhas"
}

teste_codigo_curto_nao_e_tocado()    { igual "$(pedido "$(arquivo p.py 100)" | ler)" ""; }
teste_markdown_longo_nao_e_tocado()  { igual "$(pedido "$(arquivo doc.md 5000)" | ler)" ""; }
teste_com_offset_nao_e_tocado()      { igual "$(pedido "$(arquivo g.ts 2000)" '{offset:10}' | ler)" ""; }
teste_com_limit_nao_e_tocado()       { igual "$(pedido "$(arquivo g.ts 2000)" '{limit:50}' | ler)" ""; }
teste_allow_large_nao_e_tocado()     { igual "$(pedido "$(arquivo g.ts 2000)" '{allow_large:true}' | ler)" ""; }
teste_arquivo_inexistente_nao_quebra() { igual "$(pedido "$HOME/nao-existe.py" | ler)" ""; }

teste_limites_conf_e_respeitado() {
  mkdir -p "$CLAUDE_DIR/economia"; printf 'LER_MIN_LINHAS=50\nLER_LIMITE=20\n' > "$CLAUDE_DIR/economia/limites.conf"
  igual "$(pedido "$(arquivo m.go 60)" | ler | jq -r '.hookSpecificOutput.updatedInput.limit')" "20"
}
