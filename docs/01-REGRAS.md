# 01 · Regras

Vivem em `~/.claude/CLAUDE.md` (camada global) e valem para todos os projetos.
**Precedência:** o `CLAUDE.md` do projeto vence a camada global quando os dois discordarem.
Meta: gastar o mínimo de tokens sem perder qualidade. Responder sempre em pt-BR.

## Regras de sempre

- **Resposta primeiro** (estilo caveman lite): sem preâmbulo, recapitulação nem elogio.
  Avisos de segurança e ações irreversíveis vão em frases completas.
- **Ler só o necessário**: Glob/Grep antes de abrir; `Read` com offset/limit no trecho que interessa.
- **Não reler** arquivo recém-editado; **não repetir** comando para "conferir".
- **Pedido vago** ("melhora isso") → perguntar o escopo em 1 frase antes de varrer o projeto.
- **Delegar o verboso** (ver [02-AGENTES](02-AGENTES.md)):
  - busca em muitos arquivos, documentação, web → `pesquisador-barato` (Haiku), devolve só resumo;
  - testes, lint, build → `verificador` (Haiku), devolve só falhas;
  - edição de rotina já definida → `executor-rotina` (Sonnet).
- **Opus** só para arquitetura, decisão difícil ou depois que Sonnet falhou 2×.
  Sugerir `/model opusplan` ao usuário; nunca trocar sozinho.
- **Trocou de assunto** → sugerir `/clear` (o contexto antigo é pago de novo a cada mensagem).
- **Contexto ≥ 60%** → sugerir `/clear` ou `/compact` (o hook avisa).
- **Não reinventar a roda**: antes de construir, pesquisar o que já existe (nativo do Claude Code primeiro,
  depois GitHub) e adaptar.
- **Pedido claro = executar direto** e relatar; não ficar pedindo confirmação de novo
  (parar só quando faltar informação real ou houver ação irreversível/bloqueio).
- **Tamanho de `.md`**: memória, registro e documentação ≤ 300 linhas; acima disso, dividir em
  `-parte-N` (ou partes temáticas) e indexar. `MEMORY.md` e `ARVORE.md` ≤ 200 linhas.
- **Índice antes de conteúdo**: em qualquer pasta com índice (`MEMORY.md`, `INDICE.md`, `ARVORE.md`),
  ler só o índice e abrir apenas o arquivo da linha que interessa. Nunca ler a pasta inteira.

## Modos de economia

O hook `modo.sh` acrescenta a cada mensagem: `Modo de economia: VERDE/AMARELO/VERMELHO (…)`.
O modo vem do **maior** uso entre a janela de 5 h e a semanal do plano.

| Modo | Faixa | Comportamento |
|---|---|---|
| VERDE | < 50% (ou uso desconhecido / leitura com mais de 15 min) | Trabalho normal com as regras de sempre |
| AMARELO | 50% a 79% | Busca e leitura **obrigatoriamente** pelo `pesquisador-barato`; respostas curtas; nada de pesquisa ampla sem pedido explícito |
| VERMELHO | ≥ 80% | Só o pedido atual, no menor escopo; avisar em 1 linha e sugerir `/clear` ou `/model haiku` para tarefa simples; sem tarefas longas nem subagentes em paralelo; tarefas automáticas (ex.: resumo automático de sessão) adiam |

Limites ajustáveis em `~/.claude/economia/limites.conf` (ver [03-MECANICA](03-MECANICA.md)).

## Exceções

Um projeto pode declarar exceção no próprio `CLAUDE.md` (ex.: usar modelo maior e mais contexto),
mas ainda respeita o modo VERMELHO.

## Ao compactar

- **Manter**: decisões tomadas, arquivos alterados, comandos que falharam e o próximo passo.
- **Descartar**: saídas longas de ferramentas e explorações sem resultado.

## Vocabulário útil

- **"Revisão financeira"** = revisão de **uso de tokens** (contexto fixo, leituras desnecessárias, modelo certo por
  tarefa, histórico de `/usage`), não custo em dinheiro.
- **"Setor de qualidade"** = agente `revisor-qualidade`.
- **Papel de líder**: Claude analisa, delega a agentes e cobra resultados; prompts de agente
  enxutos e autocontidos; não reler o que o agente pode ler.

## O que a camada não faz

Não troca sozinha o modelo da conversa principal no meio da sessão (um hook não pode fazer isso).
Ela troca o que dá (subagentes, tamanho das respostas, escopo) e, no VERMELHO, sugere `/model` ou `/clear`.
