# Testes da barra de status (statusline.sh)

status() {   # status <json de entrada>; stderr vai para $CLAUDE_DIR/stderr
  mkdir -p "$CLAUDE_DIR/economia"
  install -m 755 "$RAIZ/claude/economia/modo.sh" "$CLAUDE_DIR/economia/modo.sh"
  printf '%s' "$1" | "$RAIZ/claude/economia/statusline.sh" 2>"$CLAUDE_DIR/stderr"
}

teste_mostra_modelo_contexto_e_limites() {
  igual "$(status "$(entrada_status 42 30 20)")" "[Sonnet] ctx 42% · 5h 30% · semana 20% · modo VERDE"
}

teste_sem_limites_mostra_custo() {
  igual "$(status "$(entrada_status 5 null null 1.5)")" "[Sonnet] ctx 5% · \$1.50 · modo VERDE"
}

teste_grava_uso_json_para_o_hook() {
  status "$(entrada_status 12 55 70)" >/dev/null
  jq_igual "$CLAUDE_DIR/economia/uso.json" '[.cinco_horas,.semanal,.contexto]' '[55,70,12]'
}

teste_sem_limites_nao_grava_uso_json() {
  status "$(entrada_status 12 null null)" >/dev/null
  nao_existe "$CLAUDE_DIR/economia/uso.json"
}

teste_modo_reflete_o_uso_recem_gravado() {
  contem "$(status "$(entrada_status 1 85 0)")" "modo VERMELHO"
}

teste_entrada_vazia_nao_quebra() {
  contem "$(status '{}')" "[?] ctx 0%"
}

teste_grava_tokens_e_mostra_cache() {
  e='{"model":{"display_name":"Sonnet"},"context_window":{"used_percentage":15,"total_input_tokens":150000},"rate_limits":{"five_hour":{"used_percentage":10},"seven_day":{"used_percentage":5}},"prompt_cache":{"hit_ratio":0.91}}'
  linha=$(status "$e")
  contem "$linha" "ctx 15% (150k)"
  contem "$linha" "cache 91%"
  jq_igual "$CLAUDE_DIR/economia/uso.json" '.tokens' '150000'
}
