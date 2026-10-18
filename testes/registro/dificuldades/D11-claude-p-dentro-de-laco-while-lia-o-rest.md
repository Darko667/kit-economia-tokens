# D11: claude -p dentro de laço while lia o resto do arquivo de tarefas

- Data: 18/10/2026

## Como resolvemos
No teste A/B (`while read tarefa; do claude -p ...; done < tarefas.txt`), o `claude -p` lia o stdin herdado
e recebia as tarefas seguintes junto com o pedido: cada rodada respondia todas e os números saíram inválidos.
Correção: `claude -p ... < /dev/null`. Vale para qualquer programa interativo chamado dentro de `while read`.
