# Regressão do BUG-002 (registro: testes/registro/bugs/002-*.md)

# BUG-002: hook sem "command" (ex.: type "prompt") fazia o jq quebrar com
# "null cannot be matched" e a instalação/desinstalação abortava.
teste_bug_002_hook_sem_command_nao_quebra_instalacao() {
  mkdir -p "$CLAUDE_DIR"
  echo '{"hooks":{"UserPromptSubmit":[{"hooks":[{"type":"prompt","prompt":"seja breve"}]}]}}' > "$CLAUDE_DIR/settings.json"
  instalar || falha "instalar.sh falhou"
  jq_igual "$CLAUDE_DIR/settings.json" '.hooks.UserPromptSubmit | length' '2'
  desinstalar || falha "desinstalar.sh falhou"
  jq_igual "$CLAUDE_DIR/settings.json" '.hooks.UserPromptSubmit[0].hooks[0].prompt' '"seja breve"'
}
