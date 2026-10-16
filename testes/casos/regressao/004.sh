# Regressão do BUG-004 (registro: testes/registro/bugs/004-*.md)

# BUG-004: se o CLAUDE.md tinha o marcador de início mas não o de fim
# (edição manual), tudo depois do marcador era apagado sem aviso.
teste_bug_004_marcador_sem_fim_nao_apaga_o_resto() {
  mkdir -p "$CLAUDE_DIR"
  printf '# Antes\n<!-- camada-economia-tokens:inicio -->\nlixo\n# Regras importantes\n' > "$CLAUDE_DIR/CLAUDE.md"
  cp "$CLAUDE_DIR/CLAUDE.md" "$HOME/original"
  instalar 2>/dev/null && falha "instalar.sh deveria recusar CLAUDE.md com marcador incompleto"
  cmp -s "$CLAUDE_DIR/CLAUDE.md" "$HOME/original" || falha "instalar.sh alterou o CLAUDE.md"
  nao_existe "$CLAUDE_DIR/economia/modo.sh"     # recusou antes de instalar qualquer coisa
  desinstalar 2>/dev/null && falha "desinstalar.sh deveria recusar CLAUDE.md com marcador incompleto"
  cmp -s "$CLAUDE_DIR/CLAUDE.md" "$HOME/original" || falha "desinstalar.sh alterou o CLAUDE.md"
}
