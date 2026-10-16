# Regressão do BUG-009 (registro: testes/registro/bugs/009-lint-pulado-em-silencio.md)

# BUG-009: lint pulado em silêncio
teste_bug_009_lint_pulado_em_silencio() {
  # sem o ShellCheck, a suíte mostrava "59 passaram, 0 falharam" sem dizer que o lint não rodou
  p="$HOME/proj"; mkdir -p "$p/testes/casos"
  cp "$RAIZ/testes/rodar.sh" "$p/testes/"; : > "$p/testes/lib.sh"
  saida=$(SHELLCHECK=programa-que-nao-existe SEM_TESTES=1 "$p/testes/rodar.sh" -q 2>&1)
  contem "$saida" "1 pulado"
  contem "$saida" "shellcheck não encontrado"
}
