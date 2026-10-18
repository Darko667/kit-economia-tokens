# Camada de economia de tokens

Uma camada fixa no Claude Code que vale para todos os seus projetos. Ela fica em `~/.claude`, então todo projeto novo já nasce com ela.

## Documentação completa

Em `docs/`: comece por [`docs/00-INDICE.md`](docs/00-INDICE.md) e abra só a parte que interessa
(regras, agentes, mecânica, qualidade, memória e processo, lições).

## O que ela faz

| Peça | O que muda | Onde fica |
|---|---|---|
| Modelo padrão Sonnet, esforço médio | Para de gastar Opus em tarefa simples. Opus só quando você pede (`/model opus` ou `/model opusplan`) | `settings.json` |
| Subagentes em Haiku por padrão | Toda busca, leitura e teste delegados rodam no modelo mais barato | `settings.json` (`CLAUDE_CODE_SUBAGENT_MODEL`) |
| 3 subagentes prontos | `pesquisador-barato` (Haiku): busca e devolve resumo. `verificador` (Haiku): roda testes e devolve só as falhas. `executor-rotina` (Sonnet): edição já decidida | `agents/` |
| Modo de economia automático | A barra de status lê o uso real do seu plano (janela de 5 h e semanal). Quando o modo muda, um hook avisa o Claude: VERDE abaixo de 50%, AMARELO de 50% a 80%, VERMELHO acima de 80%. Em cada modo ele aperta o cinto mais um pouco (regras no CLAUDE.md) | `economia/` |
| Regras de economia | Respostas curtas, ler só o trecho necessário, delegar o que é verboso, sugerir `/clear` ao mudar de assunto. O CLAUDE.md de cada projeto continua mandando | `CLAUDE.md` (bloco entre marcadores) |
| Barra de status | Mostra modelo, contexto usado (em % e em tokens), aproveitamento do cache, % da janela de 5 h e da semana, e o modo | `economia/statusline.sh` |
| Aparador de saída | Saída de comando com mais de 120 linhas chega ao Claude só com o começo, as linhas de erro e o fim; a íntegra fica num arquivo que ele pode abrir | `economia/aparar.sh` |
| Guarda de leitura | Arquivo de código com 600 linhas ou mais é lido só nas 400 primeiras, com aviso do tamanho real, quando o Claude não pediu um trecho | `economia/ler.sh` |
| Compactação em 200 mil tokens | Modelos com janela de 1M só compactariam perto de 967 mil; cada mensagem paga o contexto inteiro de novo | `settings.json` (`autoCompactWindow`) |

Os limites dos modos se ajustam em `~/.claude/economia/limites.conf`.

O que ela não faz: trocar sozinha o modelo da conversa principal no meio da sessão. O Claude Code não permite isso a partir de um hook. Ela troca o que dá para trocar sozinha (subagentes, tamanho das respostas, escopo) e, no modo VERMELHO, sugere a você o `/model` ou o `/clear`.

## Instalar (Linux, ou Windows pelo WSL)

No Windows: no PowerShell como administrador, `wsl --install`, reinicie, abra o Ubuntu e faça tudo abaixo
lá dentro (inclusive instalar e usar o Claude Code). A camada não vale para o Claude Code nativo do Windows.
Não testado no Windows.

```bash
sudo apt install -y jq git    # se ainda não tiver
git clone https://github.com/Darko667/kit-economia-tokens.git
cd kit-economia-tokens
./instalar.sh
```

Depois feche e abra o Claude Code. O instalador:
- faz backup do seu `settings.json` e `CLAUDE.md` em `~/.claude/economia/backup-<data>/`;
- mescla as configurações sem apagar as suas (hooks e permissões que você já tem continuam);
- pode ser rodado de novo sem duplicar nada.

Para desfazer: `./desinstalar.sh` (tira só o que a camada pôs; o backup continua lá).

## Testes

```bash
testes/rodar.sh          # todos
testes/rodar.sh bug      # só os de regressão
```

Cada teste roda com um HOME temporário: nunca toca o seu `~/.claude`. O `instalar.sh` roda a suíte antes e não instala se algo falhar.
Bugs e dificuldades ficam em `testes/registro/` (índice em `INDICE.md`, um arquivo por item). Registro novo: `testes/registro/novo.sh` (passo a passo em `COMO-REGISTRAR.md`).

## Prompt em blocos

`prompt/` tem todo o sistema em blocos de colar (núcleo, modos, subagentes, qualidade, processo, memória, lições).
Veja `prompt/INDICE.md`; `prompt/montar.sh B1 B4` monta só os blocos pedidos.

## Opcionais

- **caveman global** (respostas bem mais curtas):
  `npx skills add juliusbrussee/caveman`
- **rtk** (encurta a saída de comandos como git, testes e lint antes de chegar ao Claude; o projeto diz 60% a 90% a menos nessas saídas, que são só uma parte do gasto total):
  instale com o comando de uma linha do README de github.com/rtk-ai/rtk e depois rode `rtk init -g`.
  Não use `cargo install rtk`: é outro programa com o mesmo nome. O `rtk init -g` instala um hook que reescreve comandos do terminal; leia o README antes.
- **Monitor de uso no terminal**: `uv tool install claude-monitor` (Claude-Code-Usage-Monitor), mostra quanto falta para o limite.

## Hábitos que valem mais que qualquer ferramenta

1. `/clear` ao trocar de assunto. O contexto antigo é pago de novo a cada mensagem.
2. Pedido específico ("corrige a validação do CPF em validacao.py") gasta muito menos que pedido vago ("melhora o projeto").
3. `/usage` mostra o que mais gastou (skills, subagentes, MCP).
4. MCP que você não usa: desligue em `/mcp`.

## Fontes

- Claude Code, gerenciar custos: https://code.claude.com/docs/en/costs
- Configuração de modelo e esforço: https://code.claude.com/docs/en/model-config
- Subagentes: https://code.claude.com/docs/en/sub-agents
- Barra de status: https://code.claude.com/docs/en/statusline
- Hooks: https://code.claude.com/docs/en/hooks
- rtk: https://github.com/rtk-ai/rtk · caveman: https://github.com/juliusbrussee/caveman
