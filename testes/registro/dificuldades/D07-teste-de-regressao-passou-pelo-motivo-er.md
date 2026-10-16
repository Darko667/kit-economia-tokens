# D07: Teste de regressão passou pelo motivo errado

- Data: 15/10/2026

## Como resolvemos
O teste do BUG-008 passava porque o `rodar.sh` copiado tinha um aviso próprio, não pelo script ruim de propósito (o `echo $1` é só nota, abaixo do `-S warning`). Ao corrigir o `rodar.sh`, o teste ficou vermelho e revelou isso. Regra: o defeito plantado no teste tem que ser do nível que o código verifica, e conferir que a falha vem dele.
