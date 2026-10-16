# BUG-003: Desinstalar apaga agente do usuário

- Data: 15/10/2026
- Onde: `desinstalar.sh`
- Teste: `teste_bug_003_desinstalar_nao_apaga_agente_do_usuario` em `testes/casos/regressao/003.sh`

## O que acontecia
O instalador avisava "Mantido o seu verificador.md", mas o desinstalador apagava o arquivo do usuário mesmo assim.

## Correção
Só apaga o agente se for igual ao da camada (`cmp`).
