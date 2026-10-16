# Garante que registro e suíte andam juntos: todo bug em registro/bugs/ tem teste de
# regressão (e vice-versa), e o INDICE.md lista exatamente os arquivos que existem.

REG="$RAIZ/testes/registro"
numeros_no_registro() { find "$REG/bugs" -name '[0-9][0-9][0-9]-*.md' -printf '%f\n' | cut -c1-3 | sort; }
numeros_nos_testes()  { grep -ohE '^teste_bug_[0-9]{3}_' "$RAIZ"/testes/casos/*.sh "$RAIZ"/testes/casos/regressao/*.sh | grep -oE '[0-9]{3}' | sort; }
arquivos_reais()      { (cd "$REG" && find bugs dificuldades -name '*.md' | sort); }
arquivos_no_indice()  { grep -oE '(bugs|dificuldades)/[^ |]+\.md' "$REG/INDICE.md" | sort; }

teste_todo_bug_registrado_tem_teste() {
  igual "$(comm -23 <(numeros_no_registro | sort -u) <(numeros_nos_testes | sort -u) | tr '\n' ' ')" "" "bugs sem teste_bug_NNN"
}

teste_todo_teste_de_bug_esta_registrado() {
  igual "$(comm -13 <(numeros_no_registro | sort -u) <(numeros_nos_testes | sort -u) | tr '\n' ' ')" "" "teste_bug_NNN sem registro em registro/bugs/"
}

teste_numeros_nao_se_repetem() {
  igual "$(numeros_no_registro | uniq -d | tr '\n' ' ')" "" "número de bug em dois arquivos"
  igual "$(numeros_nos_testes | uniq -d | tr '\n' ' ')" "" "número de bug em dois testes"
  igual "$(cd "$REG/dificuldades" && ls | cut -d- -f1 | sort | uniq -d | tr '\n' ' ')" "" "número de dificuldade repetido"
}

teste_teste_de_bug_fica_no_arquivo_do_seu_numero() {
  for f in "$RAIZ"/testes/casos/regressao/*.sh; do
    n=$(basename "$f" .sh)
    grep -qE "^teste_bug_${n}_" "$f" || falha "casos/regressao/$n.sh não tem teste_bug_${n}_*"
  done
}

teste_indice_bate_com_os_arquivos() {
  igual "$(comm -23 <(arquivos_reais) <(arquivos_no_indice) | tr '\n' ' ')" "" "arquivos fora do INDICE.md"
  igual "$(comm -13 <(arquivos_reais) <(arquivos_no_indice) | tr '\n' ' ')" "" "INDICE.md aponta arquivo inexistente"
}

# --- o próprio novo.sh, numa cópia do registro ---
copia_registro() {
  mkdir -p "$HOME/p/testes/casos/regressao"
  cp -r "$REG" "$HOME/p/testes/registro"
  N="$HOME/p/testes/registro/novo.sh"
}

teste_novo_bug_cria_registro_teste_e_linha_no_indice() {
  copia_registro
  ultimo=$(numeros_no_registro | tail -1); prox=$(printf "%03d" $((10#${ultimo:-0} + 1)))
  "$N" bug "Ação | com acentuação" "modo.sh" >/dev/null
  f=$(ls "$HOME/p/testes/registro/bugs/$prox-"*.md) || falha "registro $prox não criado"
  contem "$(basename "$f")" "$prox-acao-com-acentuacao"
  existe "$HOME/p/testes/casos/regressao/$prox.sh"
  grep -q "^teste_bug_${prox}_acao_com_acentuacao()" "$HOME/p/testes/casos/regressao/$prox.sh" || falha "teste com nome errado"
  contem "$(cat "$HOME/p/testes/registro/INDICE.md")" "| $prox | modo.sh | Ação / com acentuação | bugs/$(basename "$f") |"
  # a linha nova entra na tabela de bugs, antes da seção de dificuldades
  linha_bug=$(grep -n "^| $prox |" "$HOME/p/testes/registro/INDICE.md" | cut -d: -f1)
  linha_dif=$(grep -n '^## Dificuldades' "$HOME/p/testes/registro/INDICE.md" | cut -d: -f1)
  [ "$linha_bug" -lt "$linha_dif" ] || falha "linha do bug caiu fora da tabela de bugs"
}

teste_novo_bug_comeca_vermelho() {
  copia_registro
  "$N" bug "qualquer" "x" >/dev/null
  f=$(ls "$HOME/p/testes/casos/regressao/"*.sh | tail -1)
  ( . "$f"; "$(grep -oE '^teste_bug_[0-9]{3}_[a-z0-9_]+' "$f")" ) 2>/dev/null && falha "teste recém-criado deveria falhar"
  true
}

teste_nova_dificuldade_numera_e_indexa() {
  copia_registro
  "$N" dificuldade "Algo difícil" >/dev/null
  n=$(cd "$HOME/p/testes/registro/dificuldades" && ls | cut -d- -f1 | sort | tail -1)
  existe "$HOME/p/testes/registro/dificuldades/$n-algo-dificil.md"
  igual "$(grep -c "^| $n | Algo difícil |" "$HOME/p/testes/registro/INDICE.md")" "1"
}
