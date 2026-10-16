# Sistema de economia de tokens — índice

Retrato completo do sistema. **Leia só esta página e abra apenas a parte que interessa.**
Cada parte tem no máximo 300 linhas (regra de tamanho de `.md`). Fonte da verdade é o código deste repositório
(instalado em `~/.claude/`); este documento é o mapa.

| Parte | Assunto | Abrir quando |
|---|---|---|
| [01-REGRAS](01-REGRAS.md) | Regras de sempre, modos VERDE/AMARELO/VERMELHO, exceção, compactação | Dúvida sobre como o Claude deve se comportar |
| [02-AGENTES](02-AGENTES.md) | Os 4 subagentes: modelo, ferramentas, regras, quando usar | Delegar ou recriar um agente |
| [03-MECANICA](03-MECANICA.md) | settings.json, barra de status, hook do modo, limites, instalador, arquivos | Mexer na camada ou recriar numa máquina nova |
| [04-QUALIDADE](04-QUALIDADE.md) | Suíte de regressão, registro de bugs/dificuldades, hook Stop, caça a bugs | Mexer em código que tem suíte |
| [05-MEMORIA-E-PROCESSO](05-MEMORIA-E-PROCESSO.md) | Memória compartilhada, resumo de sessão, árvore, processo de projeto novo | Gravar memória ou começar projeto |
| [06-LICOES-E-HABITOS](06-LICOES-E-HABITOS.md) | Armadilhas técnicas já pagas, hábitos, opcionais, fontes | Escrever scripts/hooks; revisar hábitos |

## Visão em 30 segundos

1. **Modelo certo por tarefa**: conversa principal em Sonnet (esforço médio); subagentes em Haiku; Opus só a pedido.
2. **Delegar o verboso**: busca → `pesquisador-barato`; testes → `verificador`; edição decidida → `executor-rotina`.
3. **Modo automático**: a barra de status mede o uso do plano; um hook injeta "Modo de economia: X" em cada mensagem.
4. **Regras fixas** no `~/.claude/CLAUDE.md`: resposta curta, ler só o trecho, não reler, `/clear` ao trocar de assunto.
5. **Memória enxuta**: índice de 1 linha por nota; abrir só o arquivo da linha; `.md` ≤ 300 linhas.
6. **Qualidade sem retrabalho**: todo bug vira teste permanente; hook `Stop` roda a suíte sozinho.

## Onde está cada peça

| Peça | Caminho |
|---|---|
| Código-fonte da camada (instalador, testes, prompt em blocos) | raiz deste repositório |
| Regras globais | `~/.claude/CLAUDE.md` |
| Agentes | `~/.claude/agents/*.md` |
| Scripts do modo e barra | `~/.claude/economia/` (`modo.sh`, `statusline.sh`, `limites.conf`, `uso.json`) |
| Configuração | `~/.claude/settings.json` |
| Memória única (opcional) | `~/memoria/` (ver parte 05) |
| Prompt do sistema em blocos (B1–B7) | `prompt/` |
