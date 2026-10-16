# BUG-007: gancho com espaço no caminho não roda

- Data: 15/10/2026
- Onde: testes/ganchos/ativar.sh
- Teste: `teste_bug_007_gancho_com_espaco_no_caminho_nao_roda` em `testes/casos/regressao/007.sh`

## O que acontecia
O `ativar.sh` gravava o caminho do gancho sem aspas no `settings.json`. O Claude Code roda o comando pelo shell; com espaço no caminho (`~/Minha pasta/...`), o comando virava dois argumentos e o gancho nunca rodava. Achado ao ligar o gancho em outro projeto.

## Correção
Comando gravado entre aspas; entrada antiga sem aspas é reconhecida e substituída (sem duplicar).
