# D03: Nos testes do hook, marca de tempo e edição caíam no mesmo instante do relógio e o `find -newer` não via a mudança

- Data: 15/10/2026

## Como resolvemos
Nos testes, a marca é criada 30 s no passado (`touch -d "-30 sec"`).
