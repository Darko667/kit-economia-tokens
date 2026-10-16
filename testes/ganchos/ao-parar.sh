#!/usr/bin/env bash
# Hook "Stop" do Claude Code: ao fim de cada resposta, se algum arquivo do aplicativo
# mudou desde a última execução, roda a suíte. Se falhar, grava em testes/falhas.log
# e bloqueia o encerramento até o bug ser registrado (testes/registro), ganhar teste e ser corrigido.
# Mudanças feitas à mão entre uma mensagem e outra também são pegas (compara datas dos arquivos).
set -u
export LC_ALL=C
RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
T="$RAIZ/testes"; NOME=$(basename "$RAIZ")
marca="$T/.ultima-execucao"; estado="$T/.estado"; log="$T/falhas.log"

entrada=$(cat 2>/dev/null || true)
ja_bloqueou=$(printf '%s' "$entrada" | jq -r '.stop_hook_active // false' 2>/dev/null)

# arquivos do aplicativo e da suíte; o próprio registro (testes/registro, falhas.log) não dispara
desde=(); [ -f "$marca" ] && desde=(-newer "$marca")
novos=()
while IFS= read -r f; do novos+=("${f#"$RAIZ"/}"); done < <(
  find "$RAIZ" -type f \( -name '*.sh' -o -name '*.json' -o -name '*.conf' -o -name '*.md' \) \
    ! -path '*/.git/*' ! -path "$T/registro/*.md" "${desde[@]}" 2>/dev/null | sort)
[ "${#novos[@]}" -eq 0 ] && exit 0

touch "$marca"
saida=$("$T/rodar.sh" -q 2>&1); rc=$?
resumo=$(printf '%s\n' "$saida" | grep '^Resultado:')
lista=$(printf '%s, ' "${novos[@]:0:8}"); lista=${lista%, }
agora=$(date '+%Y-%m-%d %H:%M:%S')

if [ "$rc" -eq 0 ]; then
  if [ "$(cat "$estado" 2>/dev/null)" = vermelho ]; then
    printf '%s  RESOLVIDO  %s\n' "$agora" "$resumo" >> "$log"
  fi
  echo verde > "$estado"
  jq -n --arg m "Suíte $NOME: $resumo" '{systemMessage: $m}'
  exit 0
fi

echo vermelho > "$estado"
falhas=$(printf '%s\n' "$saida" | grep '^  - ' | sed 's/^  - //')
{ printf '%s  FALHOU  %s\n' "$agora" "$resumo"
  printf '    mudou: %s\n' "$lista"
  printf '%s\n' "$falhas" | sed 's/^/    teste: /'; } >> "$log"
tail -n 300 "$log" > "$log.novo" && mv "$log.novo" "$log"   # o log não cresce sem fim

if [ "$ja_bloqueou" = true ]; then
  # já bloqueei uma vez nesta resposta: não prende o Claude em laço, só avisa
  jq -n --arg m "Suíte $NOME AINDA VERMELHA ($resumo). Veja testes/falhas.log." '{systemMessage: $m}'
  exit 0
fi

motivo="A suíte de testes de $NOME falhou depois das mudanças em: $lista.
$resumo
Testes que falharam:
$falhas

Detalhes: rode $T/rodar.sh <filtro>. Não leia o registro inteiro: consulte só testes/registro/INDICE.md. Antes de encerrar:
1. Se é bug novo: $T/registro/novo.sh bug \"<título>\" \"<onde>\" e escreva o teste em testes/casos/regressao/NNN.sh.
2. Corrija até o rodar.sh ficar verde. Não apague nem afrouxe teste de regressão antigo.
3. Se houve dificuldade (algo que custou tentativas ou exigiu contorno): $T/registro/novo.sh dificuldade \"<título>\"."
jq -n --arg r "$motivo" '{decision: "block", reason: $r}'
