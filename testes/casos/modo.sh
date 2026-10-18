# Testes do hook modo.sh (decide VERDE / AMARELO / VERMELHO)

modo()      { "$RAIZ/claude/economia/modo.sh" --so-modo; }
modo_hook() { echo '{}' | "$RAIZ/claude/economia/modo.sh"; }

teste_sem_uso_json_e_verde() {
  igual "$(modo)" "VERDE"
  contem "$(modo_hook)" "uso do plano desconhecido"
}

teste_abaixo_de_50_e_verde()        { uso 10 49.9; igual "$(modo)" "VERDE"; }
teste_50_exato_e_amarelo()          { uso 50 0;    igual "$(modo)" "AMARELO"; }
teste_79_e_amarelo()                { uso 0 79.9;  igual "$(modo)" "AMARELO"; }
teste_80_exato_e_vermelho()         { uso 80 10;   igual "$(modo)" "VERMELHO"; }
teste_usa_o_maior_dos_dois()        { uso 5 92;    igual "$(modo)" "VERMELHO"; }
teste_semanal_nulo_usa_cinco_horas() { uso 60 null; igual "$(modo)" "AMARELO"; }

teste_uso_velho_e_tratado_como_desconhecido() {
  uso 95 95 0 1000          # 1000 s > MAX_IDADE (900)
  igual "$(modo)" "VERDE"
}

teste_limites_conf_e_respeitado() {
  mkdir -p "$CLAUDE_DIR/economia"
  printf 'AMARELO=20\nVERMELHO=30\n' > "$CLAUDE_DIR/economia/limites.conf"
  uso 25 0; igual "$(modo)" "AMARELO"
  uso 31 0; igual "$(modo)" "VERMELHO"
}

teste_saida_do_hook_e_json_valido() {
  uso 55 10
  saida=$(modo_hook)
  igual "$(printf '%s' "$saida" | jq -r '.hookSpecificOutput.hookEventName')" "UserPromptSubmit"
  contem "$(printf '%s' "$saida" | jq -r '.hookSpecificOutput.additionalContext')" "Modo de economia: AMARELO (uso do plano em 55%)"
}

teste_contexto_alto_sugere_clear() {
  uso 10 10 65
  contem "$(modo_hook)" "considerar sugerir /clear"
}

teste_contexto_baixo_nao_sugere_clear() {
  uso 10 10 30
  nao_contem "$(modo_hook)" "/clear"
}

teste_uso_json_corrompido_nao_quebra() {
  mkdir -p "$CLAUDE_DIR/economia"
  echo 'isso não é json' > "$CLAUDE_DIR/economia/uso.json"
  igual "$(modo 2>/dev/null)" "VERDE"
  modo_hook 2>/dev/null | jq -e . >/dev/null || falha "hook não devolveu JSON com uso.json corrompido"
}

# contexto em tokens (janela de 1M torna o % enganoso) e linha só quando o modo muda
uso_tokens() {   # uso_tokens <cinco_horas> <tokens>
  mkdir -p "$CLAUDE_DIR/economia"
  printf '{"cinco_horas": %s, "semanal": 0, "contexto": 12, "tokens": %s, "atualizado": %s}\n' "$1" "$2" "$(date +%s)" \
    > "$CLAUDE_DIR/economia/uso.json"
}
modo_sessao() { echo "{\"session_id\":\"${1:-s1}\"}" | "$RAIZ/claude/economia/modo.sh"; }

teste_contexto_em_tokens_alto_sugere_clear() {
  uso_tokens 10 150000
  contem "$(modo_hook)" "150 mil tokens, considerar sugerir /clear"
}

teste_contexto_em_tokens_baixo_ignora_o_percentual() {
  uso_tokens 10 50000
  nao_contem "$(modo_hook)" "/clear"
}

teste_mesma_sessao_so_repete_quando_muda() {
  uso 10 10
  contem "$(modo_sessao)" "Modo de economia: VERDE"
  igual "$(modo_sessao)" "" "segunda mensagem no mesmo modo deveria ficar quieta"
  uso 60 10
  contem "$(modo_sessao)" "Modo de economia: AMARELO"
  contem "$(modo_sessao outra)" "Modo de economia: AMARELO" "outra sessão começa falando"
}

teste_modo_sempre_repete() {
  mkdir -p "$CLAUDE_DIR/economia"; echo 'MODO_SEMPRE=1' > "$CLAUDE_DIR/economia/limites.conf"
  uso 10 10
  modo_sessao >/dev/null
  contem "$(modo_sessao)" "Modo de economia: VERDE"
}

teste_esquecer_volta_a_falar_depois_de_compactar() {
  uso 10 10
  modo_sessao >/dev/null
  igual "$(modo_sessao)" ""
  echo '{"session_id":"s1","source":"compact"}' | "$RAIZ/claude/economia/modo.sh" --esquecer
  contem "$(modo_sessao)" "Modo de economia: VERDE" "depois de compactar a linha do modo deveria voltar"
}
