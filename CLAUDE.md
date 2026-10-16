# economia-tokens

Camada de economia de tokens para o Claude Code. Responder em pt-BR.

## Testes: regra fixa

- Suíte em `testes/`. Rodar: `testes/rodar.sh` (ou `testes/rodar.sh <filtro>`). Tudo roda com HOME temporário.
- O hook `Stop` (`testes/ganchos/ao-parar.sh`) roda a suíte sozinho quando algo muda e bloqueia se ficar vermelha.
- Registro em `testes/registro/`. Consultar **só** `INDICE.md` (uma linha por item) e abrir apenas o arquivo da linha
  que interessa; nunca ler a pasta inteira. Passo a passo: `COMO-REGISTRAR.md`.
- **Bug novo**: `testes/registro/novo.sh bug "<título>" "<onde>"` → escrever o teste em `testes/casos/regressao/NNN.sh` →
  confirmar que falha → corrigir → suíte verde → preencher `bugs/NNN-*.md`. Teste de regressão nunca é apagado nem afrouxado.
- **Dificuldade nova** (algo que custou tentativas ou contorno): `testes/registro/novo.sh dificuldade "<título>"`.
- Funcionalidade nova ganha teste no arquivo de `testes/casos/` correspondente.
