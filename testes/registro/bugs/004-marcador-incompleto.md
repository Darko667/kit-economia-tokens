# BUG-004: Marcador sem fim apaga o resto do CLAUDE.md

- Data: 15/10/2026
- Onde: `instalar.sh`, `desinstalar.sh`
- Teste: `teste_bug_004_marcador_sem_fim_nao_apaga_o_resto` em `testes/casos/regressao/004.sh`

## O que acontecia
Com o marcador de início da camada e sem o de fim no CLAUDE.md, tudo depois do marcador era apagado sem aviso.

## Correção
Os dois scripts recusam com erro antes de alterar qualquer coisa; o `instalar.sh` também valida o settings.json antes.
