# Regressão do BUG-003 (registro: testes/registro/bugs/003-*.md)

# BUG-003: o instalador avisa "Mantido o seu verificador.md", mas o
# desinstalador apagava o arquivo do usuário mesmo assim.
teste_bug_003_desinstalar_nao_apaga_agente_do_usuario() {
  mkdir -p "$CLAUDE_DIR/agents"
  echo 'meu verificador' > "$CLAUDE_DIR/agents/verificador.md"
  instalar; desinstalar
  igual "$(cat "$CLAUDE_DIR/agents/verificador.md" 2>/dev/null)" "meu verificador"
  nao_existe "$CLAUDE_DIR/agents/pesquisador-barato.md"
}
