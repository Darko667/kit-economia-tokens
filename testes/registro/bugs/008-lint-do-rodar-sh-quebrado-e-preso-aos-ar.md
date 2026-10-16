# BUG-008: lint do rodar.sh quebrado e preso aos arquivos de um projeto

- Data: 15/10/2026
- Onde: testes/rodar.sh
- Teste: `teste_bug_008_lint_do_rodar_sh_quebrado_e_preso_aos_ar` em `testes/casos/regressao/008.sh`

## O que acontecia
O comentário `# shellcheck, se estiver instalado` era lido como diretiva (SC1073) e o ShellCheck parava de analisar o `rodar.sh`. A lista de arquivos do lint era fixa (`instalar.sh`, `claude/economia/*.sh`), então a cópia do `rodar.sh` em outro projeto verificaria arquivos inexistentes e ficaria sempre vermelha. Achado ao instalar o ShellCheck.

## Correção
Lint genérico: todos os `.sh` do projeto (menos `testes/casos/` e `testes/lib.sh`), `shellcheck -x --source-path=SCRIPTDIR -S warning`; comentário reescrito. O lint achou em seguida um SC2155 no próprio `rodar.sh`, também corrigido.
