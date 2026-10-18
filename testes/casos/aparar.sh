# Testes do hook aparar.sh (PostToolUse do Bash: encurta saídas longas)

aparar() { "$RAIZ/claude/economia/aparar.sh"; }
# entrada_bash <n_linhas> [linha_de_erro_no_meio]
entrada_bash() {
  saida=$(seq 1 "$1" | sed 's/^/linha /')
  [ -n "${2:-}" ] && saida=$(printf '%s\n' "$saida" | sed "$(( $1 / 2 ))s/.*/$2/")
  jq -n --arg s "$saida" '{tool_name:"Bash",tool_input:{command:"x"},
    tool_response:{stdout:$s,stderr:"",interrupted:false,isImage:false}}'
}

teste_saida_curta_passa_intacta() {
  igual "$(entrada_bash 50 | aparar)" ""
}

teste_saida_longa_e_encurtada() {
  r=$(entrada_bash 1000 | aparar)
  igual "$(printf '%s' "$r" | jq -r '.hookSpecificOutput.hookEventName')" "PostToolUse"
  s=$(printf '%s' "$r" | jq -r '.hookSpecificOutput.updatedToolOutput.stdout')
  contem "$s" "linha 1"$'\n'
  contem "$s" "linha 1000"
  nao_contem "$s" "linha 500"$'\n'
  contem "$s" "linhas do meio omitidas"
  [ "$(printf '%s\n' "$s" | wc -l)" -le 80 ] || falha "saída aparada longa demais"
}

teste_mantem_linha_de_erro_do_meio() {
  s=$(entrada_bash 1000 "ERROR: deu ruim aqui" | aparar | jq -r '.hookSpecificOutput.updatedToolOutput.stdout')
  contem "$s" "ERROR: deu ruim aqui"
}

teste_integra_fica_em_arquivo() {
  s=$(entrada_bash 1000 | aparar | jq -r '.hookSpecificOutput.updatedToolOutput.stdout')
  arq=$(printf '%s' "$s" | grep -o "$CLAUDE_DIR/economia/saidas/[^]]*")
  existe "$arq"
  igual "$(wc -l < "$arq" | tr -d ' ')" "1000"
}

teste_mantem_os_outros_campos_da_saida() {
  r=$(entrada_bash 1000 | aparar)
  igual "$(printf '%s' "$r" | jq -c '.hookSpecificOutput.updatedToolOutput | [.stderr,.interrupted,.isImage]')" '["",false,false]'
}

teste_outra_ferramenta_nao_e_tocada() {
  igual "$(echo '{"tool_name":"Read","tool_response":{"stdout":"x"}}' | aparar)" ""
}

teste_zero_desliga() {
  mkdir -p "$CLAUDE_DIR/economia"; echo 'APARAR_LINHAS=0' > "$CLAUDE_DIR/economia/limites.conf"
  igual "$(entrada_bash 1000 | aparar)" ""
}

teste_entrada_invalida_nao_quebra() {
  echo 'isso não é json' | aparar >/dev/null 2>&1 || falha "saiu com erro"
}
