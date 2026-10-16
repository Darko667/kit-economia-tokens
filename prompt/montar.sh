#!/usr/bin/env bash
# Monta prompt/PROMPT-COMPLETO.md a partir dos blocos (a fonte da verdade são os blocos).
#   prompt/montar.sh            -> todos os blocos
#   prompt/montar.sh B1 B4      -> só os blocos pedidos, na saída padrão (para colar)
set -euo pipefail
D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cabecalho='# Sistema de economia de tokens
Siga os blocos abaixo. Instruções do projeto atual (CLAUDE.md, ficha) vencem em caso de conflito.'
if [ $# -gt 0 ]; then
  echo "$cabecalho"; for b in "$@"; do echo; cat "$D"/blocos/"$b"-*.md; done
  exit 0
fi
{ echo "$cabecalho"; for f in "$D"/blocos/B*.md; do echo; cat "$f"; done; } > "$D/PROMPT-COMPLETO.md"
echo "Gerado: prompt/PROMPT-COMPLETO.md ($(wc -l < "$D/PROMPT-COMPLETO.md") linhas, $(wc -c < "$D/PROMPT-COMPLETO.md") bytes)"
