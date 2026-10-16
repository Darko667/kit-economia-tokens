# Regressão do BUG-007 (registro: testes/registro/bugs/007-gancho-com-espaco-no-caminho-nao-roda.md)

# BUG-007: o ativar.sh gravava o caminho do gancho sem aspas; o Claude Code roda o comando pelo
# shell, então "Minha pasta/..." virava dois argumentos e o gancho nunca rodava.
teste_bug_007_gancho_com_espaco_no_caminho_nao_roda() {
  d="$HOME/pasta com espaço/testes/ganchos"; mkdir -p "$d" "$CLAUDE_DIR"
  cp "$RAIZ/testes/ganchos/ativar.sh" "$d/"
  printf '#!/usr/bin/env bash\ntouch "%s/rodou"\n' "$HOME" > "$d/ao-parar.sh"; chmod +x "$d/ao-parar.sh"
  # entrada antiga, sem aspas, como a gravada antes da correção: deve ser substituída, não duplicada
  jq -n --arg c "$d/ao-parar.sh" '{hooks:{Stop:[{hooks:[{type:"command",command:$c}]}]}}' > "$CLAUDE_DIR/settings.json"
  "$d/ativar.sh" >/dev/null
  jq_igual "$CLAUDE_DIR/settings.json" '.hooks.Stop | length' '1'
  echo '{}' | bash -c "$(jq -r '.hooks.Stop[0].hooks[0].command' "$CLAUDE_DIR/settings.json")" || falha "comando do gancho falhou no shell"
  existe "$HOME/rodou"
  "$d/ativar.sh" --desligar >/dev/null
  jq_igual "$CLAUDE_DIR/settings.json" '.hooks // "sem hooks"' '"sem hooks"'
}
