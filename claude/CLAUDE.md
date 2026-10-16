<!-- camada-economia-tokens:inicio -->
# Economia de tokens (camada fixa, vale para todos os projetos)

O usuário quer gastar o mínimo de tokens possível sem perder qualidade. O CLAUDE.md de cada projeto vem antes desta camada quando os dois discordarem.

## Modo de uso

Cada mensagem pode chegar com uma linha "Modo de economia: VERDE/AMARELO/VERMELHO". Ela vem do uso real do plano (janela de 5 horas e semanal).

- VERDE: trabalho normal, com as regras abaixo.
- AMARELO: delegar busca e leitura ao subagente `pesquisador-barato`; respostas curtas; nada de pesquisa ampla sem pedido explícito.
- VERMELHO: fazer só o pedido atual, no menor escopo possível; avisar o usuário em uma linha e sugerir `/clear` ou `/model haiku` para tarefas simples; não iniciar tarefas longas nem subagentes em paralelo.

## Regras de sempre

- Respostas curtas (estilo caveman lite): resposta primeiro, sem preâmbulo nem recapitulação. Avisos de segurança e ações irreversíveis em frases completas.
- Busca em muitos arquivos, leitura de documentação e pesquisa na web: delegar ao `pesquisador-barato` (Haiku), que devolve só o resumo.
- Rodar testes, lint e builds: delegar ao `verificador` (Haiku), que devolve só as falhas.
- Edição de rotina já definida: `executor-rotina` (Sonnet).
- Opus só para arquitetura, decisões difíceis ou depois que Sonnet falhou duas vezes. Ao precisar, sugerir `/model opusplan` ao usuário em vez de mudar sozinho.
- Ler só o trecho necessário de um arquivo (offset/limit), não o arquivo inteiro.
- Não reler arquivo que acabou de editar; não repetir o mesmo comando para "conferir".
- Pedido vago ("melhora isso"): perguntar o escopo em uma frase antes de varrer o projeto.
- Ao trocar de assunto, sugerir `/clear` (o contexto antigo é pago de novo a cada mensagem).

## Ao compactar

Manter: decisões tomadas, arquivos alterados, comandos que falharam e o próximo passo. Descartar: saídas longas de ferramentas e explorações sem resultado.
<!-- camada-economia-tokens:fim -->
