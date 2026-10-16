# D06: Suíte verde no terminal e vermelha no hook (locale diferente)

- Data: 15/10/2026

## Como resolvemos
O hook roda com `LC_ALL=C`; o terminal, em pt_BR. Antes de dar a suíte por verde, rodar também `LC_ALL=C testes/rodar.sh -q`.
