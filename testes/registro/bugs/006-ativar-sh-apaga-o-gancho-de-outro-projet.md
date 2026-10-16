# BUG-006: ativar.sh apaga o gancho de outro projeto

- Data: 15/10/2026
- Onde: testes/ganchos/ativar.sh
- Teste: `teste_bug_006_ativar_sh_apaga_o_gancho_de_outro_projet` em `testes/casos/regressao/006.sh`

## O que acontecia
O `ativar.sh` reconhecia o próprio gancho pelo final do caminho (`testes/ganchos/ao-parar.sh`). Ao reaproveitar o sistema de testes em outro projeto , ligar ou desligar o gancho de um apagaria o do outro.

## Correção
Comparação pelo caminho completo do gancho (`== $c`).
