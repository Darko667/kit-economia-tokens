# Regressão do BUG-008 (registro: testes/registro/bugs/008-lint-do-rodar-sh-quebrado-e-preso-aos-ar.md)

# BUG-008: o comentário "# shellcheck, se estiver instalado" era lido como diretiva (SC1073) e
# o shellcheck parava de analisar o rodar.sh; além disso a lista de arquivos era fixa, então a
# cópia do rodar.sh em outro projeto  verificava arquivos que não existem lá.
teste_bug_008_lint_do_rodar_sh_quebrado_e_preso_aos_ar() {
  grep -qE '^[[:space:]]*#[[:space:]]*shellcheck[[:space:]]*,' "$RAIZ/testes/rodar.sh" && falha "comentário vira diretiva"
  grep -q 'claude/economia' "$RAIZ/testes/rodar.sh" && falha "lista de lint presa aos arquivos da economia-tokens"
  command -v shellcheck >/dev/null || return 0
  # um projeto qualquer com um script ruim: o lint do rodar.sh tem que pegar
  p="$HOME/proj"; mkdir -p "$p/testes/casos" "$p/scripts"
  cp "$RAIZ/testes/rodar.sh" "$p/testes/"; : > "$p/testes/lib.sh"
  printf '#!/usr/bin/env bash\ncd /tmp\nrm -f lixo\n' > "$p/scripts/ruim.sh"   # SC2164: cd sem "|| exit" (aviso)
  saida=$(env -u SHELLCHECK SEM_TESTES=1 "$p/testes/rodar.sh" -q 2>&1) && falha "lint deveria reprovar scripts/ruim.sh"
  contem "$saida" "shellcheck"
}
