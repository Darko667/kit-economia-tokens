# Regressão do BUG-005 (registro: testes/registro/bugs/005-novo-sh-gera-nome-errado-com-acentos-em.md)

# BUG-005: com LC_ALL=C (como no hook Stop), o iconv troca "ç", "ã", "í" por "?" e o
# novo.sh gerava nomes como "a-o-dif-cil" em vez de "acao-dificil".
teste_bug_005_novo_sh_gera_nome_errado_com_acentos_em() {
  mkdir -p "$HOME/p/testes/casos/regressao"
  cp -r "$RAIZ/testes/registro" "$HOME/p/testes/registro"
  LC_ALL=C "$HOME/p/testes/registro/novo.sh" dificuldade "Ação difícil" >/dev/null
  LC_ALL=C "$HOME/p/testes/registro/novo.sh" bug "Ação difícil" "x" >/dev/null
  ls "$HOME/p/testes/registro/dificuldades/"*-acao-dificil.md >/dev/null 2>&1 || falha "dificuldade sem o nome acao-dificil"
  ls "$HOME/p/testes/registro/bugs/"*-acao-dificil.md >/dev/null 2>&1 || falha "bug sem o nome acao-dificil"
  grep -q '^teste_bug_[0-9]*_acao_dificil()' "$HOME/p/testes/casos/regressao/"*.sh || falha "teste sem o nome acao_dificil"
}
