# Regressão do BUG-001 (registro: testes/registro/bugs/001-*.md)

# BUG-001: no Linux em pt_BR, o printf do bash espera vírgula decimal;
# "55.7" dava "número inválido" no stderr e truncava para 55 em vez de 56.
teste_bug_001_barra_de_status_em_locale_pt_br() {
  mkdir -p "$CLAUDE_DIR/economia"
  install -m 755 "$RAIZ/claude/economia/modo.sh" "$CLAUDE_DIR/economia/modo.sh"
  saida=$(entrada_status 10 55.7 20.2 0.123 | LC_ALL=pt_BR.UTF-8 "$RAIZ/claude/economia/statusline.sh" 2>"$HOME/err")
  igual "$(cat "$HOME/err")" "" "stderr da barra de status"
  igual "$saida" "[Sonnet] ctx 10% · 5h 56% · semana 20% · modo AMARELO"
  saida=$(entrada_status 10 null null 0.125 | LC_ALL=pt_BR.UTF-8 "$RAIZ/claude/economia/statusline.sh" 2>/dev/null)
  contem "$saida" '$0.12' "custo com ponto decimal"
}
