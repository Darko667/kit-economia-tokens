# D02: Hook "após Edit/Write" não vê mudanças feitas por comando no terminal nem à mão

- Data: 15/10/2026

## Como resolvemos
Hook `Stop` que compara a data dos arquivos com `testes/.ultima-execucao`.
