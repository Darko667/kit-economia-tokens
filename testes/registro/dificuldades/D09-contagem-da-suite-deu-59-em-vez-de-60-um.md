# D09: Contagem da suíte deu 59 em vez de 60 uma vez, sem reproduzir

- Data: 15/10/2026

## Como resolvemos
Em 15/10, o `./instalar.sh` rodado pelo terminal do usuário mostrou 59 testes; logo depois, 3 execuções (direta, com `SEM_TESTES=1` e via `instalar.sh`) deram 60. Suspeita não confirmada: o passo do ShellCheck (único que depende de ambiente) não rodou naquela vez. Se repetir: rodar `testes/rodar.sh` sem `-q` no mesmo terminal e ver se a linha `✓ shellcheck` aparece.

## Desfecho (15/10/2026, causa confirmada)
- **O quê:** o `./instalar.sh` digitado com `!` rodou **em paralelo** com uma resposta do Claude (comandos com `!` rodam na hora; o resultado só é entregue ao fim da resposta). Rodou entre 16:59:05 e 16:59:23 UTC; o teste do BUG-008 só foi criado às 16:59:49 e o lint ainda era o antigo.
- **Conta:** 58 testes + 1 lint (ShellCheck instalado às 13:59:17 local, lint antigo passa) = **59**, correto para aquele instante. O "60" comparado era de um estado posterior.
- **Prova:** linha do tempo pela transcrição + `/var/log/dpkg.log` + carimbo do backup; reprodução numa cópia com o estado daquele momento deu exatamente "59 passaram, 0 falharam".
- **Lição:** antes de comparar contagens, fixar **quando** cada uma rodou e qual versão do código estava em disco. Não houve teste perdido.
