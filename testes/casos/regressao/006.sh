# Regressão do BUG-006 (registro: testes/registro/bugs/006-ativar-sh-apaga-o-gancho-de-outro-projet.md)

# BUG-006: o ativar.sh reconhecia "o seu" gancho só pelo final do caminho
# (testes/ganchos/ao-parar.sh); outro projeto com o mesmo sistema perdia o gancho dele.
teste_bug_006_ativar_sh_apaga_o_gancho_de_outro_projet() {
  mkdir -p "$CLAUDE_DIR"
  echo '{"hooks":{"Stop":[{"hooks":[{"type":"command","command":"/outro/projeto/testes/ganchos/ao-parar.sh"}]}]}}' > "$CLAUDE_DIR/settings.json"
  "$RAIZ/testes/ganchos/ativar.sh" >/dev/null
  jq_igual "$CLAUDE_DIR/settings.json" '[.hooks.Stop[].hooks[0].command] | length' '2'
  "$RAIZ/testes/ganchos/ativar.sh" --desligar >/dev/null
  jq_igual "$CLAUDE_DIR/settings.json" '[.hooks.Stop[].hooks[0].command]' '["/outro/projeto/testes/ganchos/ao-parar.sh"]'
}
