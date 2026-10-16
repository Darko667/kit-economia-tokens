# BUG-001: Barra de status quebra números em locale pt_BR

- Data: 15/10/2026
- Onde: `statusline.sh`, `modo.sh`
- Teste: `teste_bug_001_barra_de_status_em_locale_pt_br` em `testes/casos/regressao/001.sh`

## O que acontecia
No Linux em pt_BR, o `printf` do bash espera vírgula decimal. "55.7" dava "número inválido" no stderr e virava 55% (em vez de 56%); custo $1.50 aparecia como $1,00.

## Correção
`export LC_ALL=C` no topo dos dois scripts.
