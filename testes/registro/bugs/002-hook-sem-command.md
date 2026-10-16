# BUG-002: Hook sem `command` aborta instalação

- Data: 15/10/2026
- Onde: `instalar.sh`, `desinstalar.sh`
- Teste: `teste_bug_002_hook_sem_command_nao_quebra_instalacao` em `testes/casos/regressao/002.sh`

## O que acontecia
Um hook sem `command` (ex.: `type: "prompt"`) em `UserPromptSubmit` fazia o jq abortar com "null cannot be matched".

## Correção
`(.command // "")` antes do `test()` nos dois scripts.
