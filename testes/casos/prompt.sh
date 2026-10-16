# Testes do prompt em blocos (prompt/)

PR="$RAIZ/prompt"

teste_prompt_completo_esta_em_dia_com_os_blocos() {
  cp -r "$PR" "$HOME/pr"
  "$HOME/pr/montar.sh" >/dev/null
  cmp -s "$HOME/pr/PROMPT-COMPLETO.md" "$PR/PROMPT-COMPLETO.md" \
    || falha "PROMPT-COMPLETO.md desatualizado: rode prompt/montar.sh"
}

teste_blocos_curtos_e_com_cabecalho() {
  for f in "$PR"/blocos/B*.md; do
    n=$(basename "$f" | cut -d- -f1)
    head -1 "$f" | grep -q "^## $n · " || falha "$(basename "$f") sem cabeçalho '## $n · '"
    [ "$(wc -l < "$f")" -le 40 ] || falha "$(basename "$f") passou de 40 linhas"
  done
}

teste_indice_lista_todos_os_blocos() {
  for f in "$PR"/blocos/B*.md; do
    n=$(basename "$f" | cut -d- -f1)
    grep -q "^| $n " "$PR/INDICE.md" || falha "$n fora do prompt/INDICE.md"
  done
}

teste_montagem_parcial_traz_so_os_pedidos() {
  saida=$("$PR/montar.sh" B1 B4)
  contem "$saida" "## B1 · "
  contem "$saida" "## B4 · "
  nao_contem "$saida" "## B2 · "
}

teste_prompt_completo_cabe_no_orcamento() {
  [ "$(wc -c < "$PR/PROMPT-COMPLETO.md")" -le 14000 ] || falha "PROMPT-COMPLETO.md passou de 14 mil bytes (~3,5 mil tokens)"
}
