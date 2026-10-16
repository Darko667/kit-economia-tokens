# D01: Testes chamam `instalar.sh`, que roda a suíte, que chama `instalar.sh` (laço infinito)

- Data: 15/10/2026

## Como resolvemos
`rodar.sh` exporta `SEM_TESTES=1`; o `instalar.sh` só roda a suíte sem essa variável.
