# Testes do hook automático (testes/ganchos/ao-parar.sh) e do ativar.sh.
# Usam um projeto falso cujo rodar.sh só devolve o resultado pedido, para não rodar a suíte dentro dela mesma.

projeto_falso() {    # cria $P com o gancho e um rodar.sh de mentira
  P="$HOME/proj"; mkdir -p "$P/testes/ganchos" "$P/claude"
  cp "$RAIZ/testes/ganchos/ao-parar.sh" "$P/testes/ganchos/"
  cat > "$P/testes/rodar.sh" <<'EOF'
#!/usr/bin/env bash
d="$(dirname "$0")"; echo x >> "$d/rodou"
if [ "$(cat "$d/resultado")" = ok ]; then echo "Resultado: 3 passaram, 0 falharam."; exit 0; fi
printf 'Resultado: 2 passaram, 1 falharam.\n  - regressao: teste_bug_009_quebrou\n'; exit 1
EOF
  chmod +x "$P/testes/rodar.sh"
  echo ok > "$P/testes/resultado"
  echo 'x=1' > "$P/claude/app.sh"
  touch -d '-1 min' "$P/claude/app.sh" "$P/testes/rodar.sh" "$P/testes/ganchos/ao-parar.sh"
  touch -d "-30 sec" "$P/testes/.ultima-execucao"
}
gancho() { local e="${1:-}"; [ -n "$e" ] || e="{}"; printf "%s" "$e" | "$P/testes/ganchos/ao-parar.sh"; }
rodou()  { [ -f "$P/testes/rodou" ] && wc -l < "$P/testes/rodou" || echo 0; }

teste_gancho_sem_mudanca_nao_roda_a_suite() {
  projeto_falso
  igual "$(gancho)" ""
  igual "$(rodou)" "0"
}

teste_gancho_mudanca_e_suite_verde_avisa_e_nao_bloqueia() {
  projeto_falso; echo 'x=2' > "$P/claude/app.sh"
  saida=$(gancho)
  contem "$saida" "3 passaram"
  nao_contem "$saida" '"block"'
  igual "$(cat "$P/testes/.estado")" "verde"
}

teste_gancho_suite_vermelha_bloqueia_e_registra() {
  projeto_falso; echo falha > "$P/testes/resultado"; echo 'x=2' > "$P/claude/app.sh"
  saida=$(gancho)
  igual "$(printf '%s' "$saida" | jq -r .decision)" "block"
  contem "$(printf '%s' "$saida" | jq -r .reason)" "teste_bug_009_quebrou"
  contem "$(printf '%s' "$saida" | jq -r .reason)" "claude/app.sh"
  contem "$(cat "$P/testes/falhas.log")" "FALHOU"
  contem "$(cat "$P/testes/falhas.log")" "teste: regressao: teste_bug_009_quebrou"
}

teste_gancho_nao_prende_em_laco() {
  projeto_falso; echo falha > "$P/testes/resultado"; echo 'x=2' > "$P/claude/app.sh"
  saida=$(gancho '{"stop_hook_active": true}')
  igual "$(printf '%s' "$saida" | jq -r '.decision // "nenhuma"')" "nenhuma"
  contem "$saida" "AINDA VERMELHA"
}

teste_gancho_registra_quando_volta_ao_verde() {
  projeto_falso; echo falha > "$P/testes/resultado"; echo 'x=2' > "$P/claude/app.sh"
  gancho >/dev/null
  echo ok > "$P/testes/resultado"; sleep 1; echo 'x=3' > "$P/claude/app.sh"
  gancho >/dev/null
  contem "$(cat "$P/testes/falhas.log")" "RESOLVIDO"
}

teste_gancho_editar_registro_nao_dispara() {
  projeto_falso; sleep 1; mkdir -p "$P/testes/registro"; echo '| 009 |' > "$P/testes/registro/INDICE.md"
  igual "$(gancho)" ""
  igual "$(rodou)" "0"
}

teste_gancho_primeira_vez_roda() {
  projeto_falso; rm "$P/testes/.ultima-execucao"
  gancho >/dev/null
  igual "$(rodou)" "1"
}

teste_ativar_liga_desliga_sem_duplicar_nem_apagar() {
  mkdir -p "$CLAUDE_DIR"
  echo '{"hooks":{"Stop":[{"hooks":[{"type":"command","command":"meu.sh"}]}]},"model":"opus"}' > "$CLAUDE_DIR/settings.json"
  "$RAIZ/testes/ganchos/ativar.sh" >/dev/null
  "$RAIZ/testes/ganchos/ativar.sh" >/dev/null
  jq_igual "$CLAUDE_DIR/settings.json" '[.hooks.Stop[].hooks[0].command | sub(".*/";"") | rtrimstr("\"")]' '["meu.sh","ao-parar.sh"]'
  "$RAIZ/testes/ganchos/ativar.sh" --desligar >/dev/null
  jq_igual "$CLAUDE_DIR/settings.json" '.' '{"hooks":{"Stop":[{"hooks":[{"type":"command","command":"meu.sh"}]}]},"model":"opus"}'
}

teste_instalar_camada_preserva_o_gancho_de_testes() {
  "$RAIZ/testes/ganchos/ativar.sh" >/dev/null
  instalar
  jq_igual "$CLAUDE_DIR/settings.json" '[.hooks.Stop[].hooks[0].command | sub(".*/";"") | rtrimstr("\"")]' '["ao-parar.sh"]'
  desinstalar
  jq_igual "$CLAUDE_DIR/settings.json" '[.hooks.Stop[].hooks[0].command | sub(".*/";"") | rtrimstr("\"")]' '["ao-parar.sh"]'
}
