# Como registrar

Bug: o que o programa faz de errado. Dificuldade: algo que custou tentativas ou exigiu contorno.

## Bug novo
1. `testes/registro/novo.sh bug "<título curto>" "<arquivo(s) onde está>"`
   Cria `bugs/NNN-*.md`, a linha no `INDICE.md` e `casos/regressao/NNN.sh` com um teste que falha de propósito.
2. Escreva o teste em `casos/regressao/NNN.sh` reproduzindo o bug; `testes/rodar.sh bug_NNN` deve **falhar**.
3. Corrija o código até `testes/rodar.sh` ficar verde.
4. Preencha "O que acontecia" e "Correção" em `bugs/NNN-*.md`.

Teste de regressão nunca é apagado nem afrouxado.

## Dificuldade nova
`testes/registro/novo.sh dificuldade "<título>"` e preencha "Como resolvemos" no arquivo criado.

## Quando a suíte roda sozinha
- No Claude Code, ao fim de cada resposta (hook `Stop`, `testes/ganchos/ativar.sh`), se algum arquivo mudou.
  Vermelho: grava em `testes/falhas.log` (só as últimas 300 linhas) e bloqueia o encerramento.
- No `instalar.sh`: vermelho = nada é instalado.
- `casos/registro.sh` confere que índice, arquivos e testes batem.
