# BUG-005: novo.sh gera nome errado com acentos em locale C

- Data: 15/10/2026
- Onde: testes/registro/novo.sh
- Teste: `teste_bug_005_novo_sh_gera_nome_errado_com_acentos_em` em `testes/casos/regressao/005.sh`

## O que acontecia
Com `LC_ALL=C` (o locale do hook Stop), o `iconv //TRANSLIT` troca "ç", "ã", "í" por "?"; o `novo.sh` gerava nomes como `a-o-dif-cil` em vez de `acao-dificil`. A suíte passava no terminal (pt_BR) e falhava no hook.

## Correção
`LC_ALL=C.UTF-8` só no `iconv` do `novo.sh`.
