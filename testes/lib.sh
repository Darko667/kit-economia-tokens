# Auxiliares dos testes. Carregado pelo rodar.sh antes de cada arquivo de casos.
# Cada teste roda num subshell com HOME temporário: nada toca o seu ~/.claude real.

RAIZ="${RAIZ:?}"            # pasta do projeto (definida pelo rodar.sh)
CLAUDE_DIR="$HOME/.claude"

falha() { echo "    $*" >&2; exit 1; }

igual() {        # igual <obtido> <esperado> [mensagem]
  [ "$1" = "$2" ] || falha "${3:-valor diferente}: esperado [$2], veio [$1]"
}

contem() {       # contem <texto> <trecho> [mensagem]
  case "$1" in *"$2"*) ;; *) falha "${3:-trecho ausente}: [$2] não está em [$1]" ;; esac
}

nao_contem() {
  case "$1" in *"$2"*) falha "${3:-trecho indevido}: [$2] está em [$1]" ;; esac
}

existe()     { [ -e "$1" ] || falha "deveria existir: $1"; }
nao_existe() { [ ! -e "$1" ] || falha "não deveria existir: $1"; }

jq_igual() {     # jq_igual <arquivo> <filtro> <esperado>
  igual "$(jq -c "$2" "$1")" "$3" "jq $2 em $(basename "$1")"
}

instalar()    { "$RAIZ/instalar.sh" "$@" >/dev/null; }
desinstalar() { "$RAIZ/desinstalar.sh" >/dev/null; }

# grava um uso.json como a barra de status grava
uso() {          # uso <cinco_horas> <semanal> [contexto] [idade_em_segundos]
  mkdir -p "$CLAUDE_DIR/economia"
  printf '{"cinco_horas": %s, "semanal": %s, "contexto": %s, "atualizado": %s}\n' \
    "$1" "$2" "${3:-0}" "$(( $(date +%s) - ${4:-0} ))" > "$CLAUDE_DIR/economia/uso.json"
}

# entrada que o Claude Code manda para a barra de status
entrada_status() {   # entrada_status <ctx> <cinco_horas|null> <semanal|null> [custo]
  printf '{"model":{"display_name":"Sonnet"},"context_window":{"used_percentage":%s},"rate_limits":{"five_hour":{"used_percentage":%s},"seven_day":{"used_percentage":%s}},"cost":{"total_cost_usd":%s}}' \
    "$1" "$2" "$3" "${4:-0}"
}
