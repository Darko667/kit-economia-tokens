# D12: Variáveis da sessão na nuvem vazavam para o claude -p do teste A/B

- Data: 18/10/2026

## Como resolvemos
Rodando o `claude -p` do teste A/B dentro de uma sessão do Claude Code na nuvem, variáveis como
`CLAUDE_CODE_SESSION_ID`, compactação automática e esforço passavam para o filho e mudavam o comportamento,
mesmo com HOME isolado. Correção: uma função `limpo()` que roda o comando com `env -u` em todas as variáveis
`CLAUDE*`, `CCR_*` e `AI_AGENT*`, mantendo só as de credencial (`CLAUDE_SESSION_INGRESS_TOKEN_FILE`,
`CLAUDE_CODE_ACCOUNT_UUID`, `CLAUDE_CODE_ORGANIZATION_UUID`, `CLAUDE_CODE_USER_EMAIL`).
