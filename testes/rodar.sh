#!/usr/bin/env bash
# Roda a suíte de testes da camada de economia de tokens.
#   testes/rodar.sh            -> todos os testes
#   testes/rodar.sh bug        -> só os testes cujo nome (ou arquivo) contém "bug"
#   testes/rodar.sh -q         -> silencioso: só mostra falhas e o resumo
# Cada função teste_* de testes/casos/*.sh e casos/regressao/*.sh roda isolada, com HOME temporário.
set -u
shopt -s nullglob   # pasta de casos vazia não vira nome literal
RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"; export RAIZ
CASOS="$RAIZ/testes/casos"
export SEM_TESTES=1   # o instalar.sh chamado pelos testes não roda a suíte de novo
QUIETO=0; FILTRO=""
for arg in "$@"; do
  case "$arg" in -q) QUIETO=1 ;; *) FILTRO="$arg" ;; esac
done

command -v jq >/dev/null || { echo "Falta o jq. Instale com: sudo apt install jq"; exit 1; }

ok=0; ruim=0; pulados=0; falhas=()
for arquivo in "$CASOS"/*.sh "$CASOS"/regressao/*.sh; do
  rotulo=${arquivo#"$CASOS"/}; rotulo=${rotulo%.sh}
  testes=$(bash -c ". '$arquivo'; declare -F" | awk '$3 ~ /^teste_/ {print $3}')
  for t in $testes; do
    [ -n "$FILTRO" ] && [[ "$rotulo:$t" != *"$FILTRO"* ]] && continue
    casa=$(mktemp -d)
    saida=$(
      cd "$casa" && HOME="$casa" bash -c "
        set -u
        . '$RAIZ/testes/lib.sh'
        . '$arquivo'
        $t
      " 2>&1
    )
    if [ $? -eq 0 ]; then
      ok=$((ok + 1)); [ "$QUIETO" -eq 1 ] || echo "  ✓ $t"
    else
      ruim=$((ruim + 1)); falhas+=("$rotulo: $t")
      echo "  ✗ $t  ($rotulo)"
      [ -n "$saida" ] && printf '%s\n' "$saida" | tail -15
    fi
    rm -rf "$casa"
  done
done

# Lint com o ShellCheck, se instalado (sudo apt install shellcheck): todos os .sh do projeto,
# menos os casos de teste e o lib.sh (trechos carregados pelo rodar.sh); só avisos e erros (BUG-008).
# Sem o ShellCheck, o passo conta como pulado e a suíte avisa (BUG-009). SHELLCHECK troca o programa.
SHELLCHECK="${SHELLCHECK:-shellcheck}"
if [ -n "$FILTRO" ]; then
  :
elif ! command -v "$SHELLCHECK" >/dev/null; then
  pulados=$((pulados + 1)); echo "  - shellcheck não encontrado: lint pulado (sudo apt install shellcheck)"
else
  mapfile -t scripts < <(find "$RAIZ" -name '*.sh' -not -path '*/testes/casos/*' -not -path '*/.git/*' -not -path '*/testes/lib.sh' | sort)
  if [ "${#scripts[@]}" -eq 0 ] || lint=$("$SHELLCHECK" -x --source-path=SCRIPTDIR -S warning "${scripts[@]}" 2>&1); then
    ok=$((ok + 1)); [ "$QUIETO" -eq 1 ] || echo "  ✓ shellcheck (${#scripts[@]} scripts)"
  else
    ruim=$((ruim + 1)); falhas+=("shellcheck")
    echo "  ✗ shellcheck"; printf '%s\n' "$lint" | grep -E '^In |SC[0-9]+' | head -20
  fi
fi

echo
echo "Resultado: $ok passaram, $ruim falharam$([ "$pulados" -gt 0 ] && echo ", $pulados pulado")."
[ "$ruim" -eq 0 ] || { printf '  - %s\n' "${falhas[@]}"; exit 1; }
