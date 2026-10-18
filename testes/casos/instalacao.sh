# Testes do instalar.sh e do desinstalar.sh

teste_instala_em_home_vazio() {
  instalar
  existe "$CLAUDE_DIR/economia/modo.sh"
  existe "$CLAUDE_DIR/economia/statusline.sh"
  existe "$CLAUDE_DIR/economia/limites.conf"
  existe "$CLAUDE_DIR/agents/verificador.md"
  [ -x "$CLAUDE_DIR/economia/modo.sh" ] || falha "modo.sh sem permissão de execução"
  jq_igual "$CLAUDE_DIR/settings.json" '[.model,.effortLevel,.env.CLAUDE_CODE_SUBAGENT_MODEL]' '["sonnet","medium","haiku"]'
  contem "$(cat "$CLAUDE_DIR/CLAUDE.md")" "<!-- camada-economia-tokens:inicio -->"
}

teste_preserva_settings_do_usuario() {
  mkdir -p "$CLAUDE_DIR"
  cat > "$CLAUDE_DIR/settings.json" <<'EOF'
{"permissions":{"allow":["Bash(ls)"]},"env":{"MEU":"1"},
 "hooks":{"PreToolUse":[{"hooks":[{"type":"command","command":"meu.sh"}]}],
          "UserPromptSubmit":[{"hooks":[{"type":"command","command":"outro.sh"}]}]}}
EOF
  instalar
  f="$CLAUDE_DIR/settings.json"
  jq_igual "$f" '.permissions.allow' '["Bash(ls)"]'
  jq_igual "$f" '.env.MEU' '"1"'
  jq_igual "$f" '.hooks.PreToolUse[0].hooks[0].command' '"meu.sh"'
  jq_igual "$f" '[.hooks.UserPromptSubmit[].hooks[0].command]' '["outro.sh","~/.claude/economia/modo.sh"]'
}

teste_preserva_texto_do_claude_md() {
  mkdir -p "$CLAUDE_DIR"
  printf '# Minhas regras\n\nResponder em pt-BR.\n' > "$CLAUDE_DIR/CLAUDE.md"
  instalar
  contem "$(cat "$CLAUDE_DIR/CLAUDE.md")" "Responder em pt-BR."
}

teste_rodar_duas_vezes_nao_duplica() {
  mkdir -p "$CLAUDE_DIR"
  printf '# Minhas regras\n' > "$CLAUDE_DIR/CLAUDE.md"
  instalar
  cp "$CLAUDE_DIR/CLAUDE.md" "$HOME/claude1"; cp "$CLAUDE_DIR/settings.json" "$HOME/settings1"
  instalar
  cmp -s "$CLAUDE_DIR/CLAUDE.md" "$HOME/claude1"  || falha "CLAUDE.md mudou na segunda instalação"
  cmp -s "$CLAUDE_DIR/settings.json" "$HOME/settings1" || falha "settings.json mudou na segunda instalação"
  igual "$(grep -c 'camada-economia-tokens:inicio' "$CLAUDE_DIR/CLAUDE.md")" "1"
}

teste_faz_backup_antes() {
  mkdir -p "$CLAUDE_DIR"
  echo '{"model":"opus"}' > "$CLAUDE_DIR/settings.json"
  instalar
  b=$(ls -d "$CLAUDE_DIR"/economia/backup-* | head -1)
  jq_igual "$b/settings.json" '.model' '"opus"'
}

teste_nao_sobrescreve_limites_conf_do_usuario() {
  mkdir -p "$CLAUDE_DIR/economia"
  echo 'AMARELO=10' > "$CLAUDE_DIR/economia/limites.conf"
  instalar
  igual "$(cat "$CLAUDE_DIR/economia/limites.conf")" "AMARELO=10"
}

teste_nao_sobrescreve_agente_do_usuario_sem_forcar() {
  mkdir -p "$CLAUDE_DIR/agents"
  echo 'meu verificador' > "$CLAUDE_DIR/agents/verificador.md"
  instalar
  igual "$(cat "$CLAUDE_DIR/agents/verificador.md")" "meu verificador"
  instalar --forcar
  cmp -s "$CLAUDE_DIR/agents/verificador.md" "$RAIZ/claude/agents/verificador.md" || falha "--forcar não substituiu"
}

teste_desinstalar_volta_ao_estado_original() {
  mkdir -p "$CLAUDE_DIR"
  printf '# Minhas regras\n' > "$CLAUDE_DIR/CLAUDE.md"
  echo '{"permissions":{"allow":["Bash(ls)"]}}' > "$CLAUDE_DIR/settings.json"
  instalar; desinstalar
  jq_igual "$CLAUDE_DIR/settings.json" '.' '{"permissions":{"allow":["Bash(ls)"]}}'
  nao_contem "$(cat "$CLAUDE_DIR/CLAUDE.md")" "camada-economia-tokens"
  contem "$(cat "$CLAUDE_DIR/CLAUDE.md")" "# Minhas regras"
  nao_existe "$CLAUDE_DIR/economia/modo.sh"
  nao_existe "$CLAUDE_DIR/agents/verificador.md"
}

teste_desinstalar_mantem_hooks_do_usuario() {
  mkdir -p "$CLAUDE_DIR"
  echo '{"hooks":{"UserPromptSubmit":[{"hooks":[{"type":"command","command":"outro.sh"}]}]}}' > "$CLAUDE_DIR/settings.json"
  instalar; desinstalar
  jq_igual "$CLAUDE_DIR/settings.json" '[.hooks.UserPromptSubmit[].hooks[0].command]' '["outro.sh"]'
}

teste_settings_invalido_aborta_sem_estragar() {
  mkdir -p "$CLAUDE_DIR"
  echo '{ quebrado' > "$CLAUDE_DIR/settings.json"
  instalar 2>/dev/null && falha "deveria ter falhado com settings.json inválido"
  igual "$(cat "$CLAUDE_DIR/settings.json")" "{ quebrado"
  nao_existe "$CLAUDE_DIR/economia/modo.sh"     # nada instalado pela metade
}

teste_instala_ganchos_novos_sem_duplicar() {
  instalar; instalar
  f="$CLAUDE_DIR/settings.json"
  jq_igual "$f" '[.hooks.PreToolUse[].hooks[0].command]' '["~/.claude/economia/ler.sh"]'
  jq_igual "$f" '[.hooks.PostToolUse[].hooks[0].command]' '["~/.claude/economia/aparar.sh"]'
  jq_igual "$f" '[.hooks.SessionStart[].hooks[0].command]' '["~/.claude/economia/modo.sh --esquecer"]'
  jq_igual "$f" '.autoCompactWindow' '200000'
  [ -x "$CLAUDE_DIR/economia/aparar.sh" ] || falha "aparar.sh sem permissão de execução"
  [ -x "$CLAUDE_DIR/economia/ler.sh" ] || falha "ler.sh sem permissão de execução"
}

teste_desinstalar_tira_ganchos_novos_e_mantem_os_do_usuario() {
  mkdir -p "$CLAUDE_DIR"
  echo '{"hooks":{"PreToolUse":[{"hooks":[{"type":"command","command":"meu.sh"}]}]}}' > "$CLAUDE_DIR/settings.json"
  instalar; desinstalar
  jq_igual "$CLAUDE_DIR/settings.json" '.' '{"hooks":{"PreToolUse":[{"hooks":[{"type":"command","command":"meu.sh"}]}]}}'
  nao_existe "$CLAUDE_DIR/economia/aparar.sh"
  nao_existe "$CLAUDE_DIR/economia/ler.sh"
}
