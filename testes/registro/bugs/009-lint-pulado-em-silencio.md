# BUG-009: lint pulado em silêncio

- Data: 15/10/2026
- Onde: testes/rodar.sh
- Teste: `teste_bug_009_lint_pulado_em_silencio` em `testes/casos/regressao/009.sh`

## O que acontecia
Sem o ShellCheck no caminho, o `rodar.sh` pulava o lint sem dizer nada: o total caía um e nada indicava o motivo. Achado ao investigar o "59 passaram" de 15/10 — **que não foi causado por este bug** (causa real em `dificuldades/D09-*`: o comando rodou num estado anterior, com 58 testes + lint). O defeito é real mesmo assim e tem teste.

## Correção
Lint ausente vira "N pulado" no resultado, com a linha "shellcheck não encontrado: lint pulado". Variável `SHELLCHECK` permite testar o caso.
