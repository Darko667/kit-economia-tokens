#!/usr/bin/env bash
# Cria um registro novo sem precisar ler os existentes.
#   novo.sh bug "<título>" "<onde>"   -> bugs/NNN-*.md, linha no INDICE.md e casos/regressao/NNN.sh
#                                        (o teste criado falha de propósito até ser escrito)
#   novo.sh dificuldade "<título>"    -> dificuldades/DNN-*.md e linha no INDICE.md
set -euo pipefail
R="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
T="$(dirname "$R")"
tipo="${1:-}"; titulo="${2:-}"; onde="${3:-?}"
[ -n "$titulo" ] && { [ "$tipo" = bug ] || [ "$tipo" = dificuldade ]; } \
  || { echo 'Uso: novo.sh bug|dificuldade "<título>" ["<onde>"]' >&2; exit 1; }
titulo=${titulo//|//}; onde=${onde//|//}   # "|" quebraria a tabela do índice
# iconv só troca "ç"→"c" num locale UTF-8; em LC_ALL=C (o do hook) viraria "?" (BUG-005)
slug=$(printf '%s' "$titulo" | LC_ALL=C.UTF-8 iconv -f utf-8 -t ascii//TRANSLIT 2>/dev/null | tr 'A-Z' 'a-z' \
  | tr -cs 'a-z0-9' '-' | cut -c1-40 | sed 's/^-*//; s/-*$//')
[ -n "$slug" ] || slug=sem-titulo
hoje=$(date +%d/%m/%Y)

ultimo() {   # maior número já usado na pasta $1 com prefixo $2
  local u; u=$(find "$1" -maxdepth 1 -name "$2[0-9]*" -printf '%f\n' 2>/dev/null \
    | grep -oE "^$2[0-9]+" | grep -oE '[0-9]+' | sort -n | tail -1)
  echo $((10#${u:-0}))
}

no_indice() {  # no_indice <seção> <linha>: insere a linha no fim da tabela da seção
  local alvo
  alvo=$(awk -v s="$1" '$0==s{d=1;next} /^## /{d=0} d && /^\|/{n=NR} END{print n}' "$R/INDICE.md")
  awk -v n="$alvo" -v l="$2" '{print} NR==n{print l}' "$R/INDICE.md" > "$R/INDICE.md.novo"
  mv "$R/INDICE.md.novo" "$R/INDICE.md"
}

if [ "$tipo" = bug ]; then
  n=$(printf '%03d' $(( $(ultimo "$R/bugs" "") + 1 )))
  f="bugs/$n-$slug.md"
  teste="teste_bug_${n}_${slug//-/_}"
  cat > "$R/$f" <<EOF
# BUG-$n: $titulo

- Data: $hoje
- Onde: $onde
- Teste: \`$teste\` em \`testes/casos/regressao/$n.sh\`

## O que acontecia
(preencher)

## Correção
(preencher)
EOF
  cat > "$T/casos/regressao/$n.sh" <<EOF
# Regressão do BUG-$n (registro: testes/registro/$f)

# BUG-$n: $titulo
$teste() {
  falha "BUG-$n: teste ainda não escrito (testes/casos/regressao/$n.sh)"
}
EOF
  no_indice "## Bugs" "| $n | $onde | $titulo | $f |"
  echo "Criados: testes/registro/$f e testes/casos/regressao/$n.sh (teste $teste)"
else
  n=$(printf 'D%02d' $(( $(ultimo "$R/dificuldades" D) + 1 )))
  f="dificuldades/$n-$slug.md"
  cat > "$R/$f" <<EOF
# $n: $titulo

- Data: $hoje

## Como resolvemos
(preencher)
EOF
  no_indice "## Dificuldades" "| $n | $titulo | $f |"
  echo "Criado: testes/registro/$f"
fi
