#!/usr/bin/env bash
# Instala a camada de economia de tokens em ~/.claude (vale para todos os projetos).
# Faz backup antes, não apaga nada seu e pode ser rodado de novo sem duplicar.
set -euo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORIGEM="$AQUI/claude"
CLAUDE_DIR="${HOME}/.claude"
DATA="$(date +%Y%m%d-%H%M%S)"
BACKUP="$CLAUDE_DIR/economia/backup-$DATA"
FORCAR=0
[ "${1:-}" = "--forcar" ] && FORCAR=1

command -v jq >/dev/null || { echo "Falta o jq. Instale com: sudo apt install jq"; exit 1; }

# roda a suíte antes: uma versão com teste quebrado não chega ao seu ~/.claude
# (o rodar.sh define SEM_TESTES=1 para não entrar em laço quando os testes chamam este script)
if [ "${SEM_TESTES:-0}" != 1 ] && [ -x "$AQUI/testes/rodar.sh" ]; then
  echo "Rodando os testes..."
  "$AQUI/testes/rodar.sh" -q || { echo "Testes falharam; nada foi instalado." >&2; exit 1; }
fi

INI='<!-- camada-economia-tokens:inicio -->'
FIM='<!-- camada-economia-tokens:fim -->'

# 0. confere antes de mexer em qualquer coisa (BUG-004)
if [ -f "$CLAUDE_DIR/settings.json" ] && ! jq empty "$CLAUDE_DIR/settings.json" 2>/dev/null; then
  echo "Erro: $CLAUDE_DIR/settings.json não é um JSON válido. Corrija e rode de novo; nada foi alterado." >&2
  exit 1
fi
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
  n_ini=$(grep -cxF "$INI" "$CLAUDE_DIR/CLAUDE.md" || true)
  n_fim=$(grep -cxF "$FIM" "$CLAUDE_DIR/CLAUDE.md" || true)
  if [ "$n_ini" != "$n_fim" ]; then
    echo "Erro: $CLAUDE_DIR/CLAUDE.md tem marcadores da camada incompletos ($n_ini início, $n_fim fim)." >&2
    echo "Corrija à mão e rode de novo; nada foi alterado." >&2
    exit 1
  fi
fi

mkdir -p "$CLAUDE_DIR/agents" "$CLAUDE_DIR/economia" "$BACKUP"
[ -f "$CLAUDE_DIR/settings.json" ] && cp "$CLAUDE_DIR/settings.json" "$BACKUP/"
[ -f "$CLAUDE_DIR/CLAUDE.md" ] && cp "$CLAUDE_DIR/CLAUDE.md" "$BACKUP/"
echo "Backup em $BACKUP"

# 1. scripts e limites (limites.conf só se ainda não existir: é seu para ajustar)
install -m 755 "$ORIGEM/economia/statusline.sh" "$CLAUDE_DIR/economia/statusline.sh"
install -m 755 "$ORIGEM/economia/modo.sh" "$CLAUDE_DIR/economia/modo.sh"
install -m 755 "$ORIGEM/economia/aparar.sh" "$CLAUDE_DIR/economia/aparar.sh"
install -m 755 "$ORIGEM/economia/ler.sh" "$CLAUDE_DIR/economia/ler.sh"
[ -f "$CLAUDE_DIR/economia/limites.conf" ] || install -m 644 "$ORIGEM/economia/limites.conf" "$CLAUDE_DIR/economia/limites.conf"

# 2. subagentes (não sobrescreve um de mesmo nome, a menos que --forcar)
for a in "$ORIGEM"/agents/*.md; do
  destino="$CLAUDE_DIR/agents/$(basename "$a")"
  if [ -f "$destino" ] && [ "$FORCAR" -eq 0 ] && ! cmp -s "$a" "$destino"; then
    echo "Mantido o seu $(basename "$a") (use --forcar para substituir)"
  else
    install -m 644 "$a" "$destino"
  fi
done

# 3. CLAUDE.md global: troca só o bloco entre os marcadores
touch "$CLAUDE_DIR/CLAUDE.md"
tmp="$(mktemp)"
awk -v ini="$INI" -v fim="$FIM" '$0==ini{pular=1} !pular{print} $0==fim{pular=0}' "$CLAUDE_DIR/CLAUDE.md" > "$tmp"
# tira linhas em branco sobrando no fim antes de anexar o bloco
sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$tmp" > "$tmp.2"
{ cat "$tmp.2"; [ -s "$tmp.2" ] && echo; cat "$ORIGEM/CLAUDE.md"; } > "$CLAUDE_DIR/CLAUDE.md"
rm -f "$tmp" "$tmp.2"

# 4. settings.json: mescla sem apagar o que já existe
[ -f "$CLAUDE_DIR/settings.json" ] || echo '{}' > "$CLAUDE_DIR/settings.json"
anterior_status=$(jq -r '.statusLine.command // empty' "$CLAUDE_DIR/settings.json")
# shellcheck disable=SC2088  # comparação com o texto literal gravado no settings.json
if [ -n "$anterior_status" ] && [ "$anterior_status" != "~/.claude/economia/statusline.sh" ]; then
  echo "Aviso: sua barra de status ($anterior_status) foi trocada pela da camada. A antiga está no backup."
fi
jq -s '
  .[0] as $atual | .[1] as $camada
  | def da_camada: (.hooks // []) | any((.command // "") | test("economia/(modo|ler|aparar)\\.sh"));
  $atual
  | .model = $camada.model
  | .effortLevel = $camada.effortLevel
  | .autoCompactWindow = $camada.autoCompactWindow
  | .env = ((.env // {}) + $camada.env)
  | .statusLine = $camada.statusLine
  | .hooks = (reduce ($camada.hooks | keys[]) as $ev ((.hooks // {});
      .[$ev] = (((.[$ev] // []) | map(select(da_camada | not))) + $camada.hooks[$ev])))
' "$CLAUDE_DIR/settings.json" "$ORIGEM/settings.camada.json" > "$CLAUDE_DIR/settings.json.novo"
mv "$CLAUDE_DIR/settings.json.novo" "$CLAUDE_DIR/settings.json"

echo
echo "Camada instalada. Feche e abra o Claude Code para valer."
echo "Opcional (mais economia):"
echo "  - rtk, que encurta a saída de comandos no terminal: veja LEIA-ME.md"
echo "  - skill caveman global: npx skills add juliusbrussee/caveman"
