# 03 · Mecânica (como a camada funciona por dentro)

## settings.json (`~/.claude/settings.json`)

| Chave | Valor | Efeito |
|---|---|---|
| `model` | `sonnet` | Conversa principal sai do Opus por padrão |
| `effortLevel` | `medium` | Menos raciocínio gasto em tarefa simples |
| `env.CLAUDE_CODE_SUBAGENT_MODEL` | `haiku` | Subagentes no modelo mais barato |
| `autoCompactWindow` | `200000` | Compacta em 200 mil tokens (sem isso, modelos com janela de 1M só compactam perto de 967 mil) |
| `env.CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION` | `false` | Desliga as sugestões de próximo pedido (cada uma é uma chamada extra) |
| `statusLine` | `~/.claude/economia/statusline.sh` | Barra de status + medição do uso |
| hook `UserPromptSubmit` | `~/.claude/economia/modo.sh` (timeout 5) | Injeta o modo quando ele muda |
| hook `SessionStart` (`compact\|clear`) | `~/.claude/economia/modo.sh --esquecer` (timeout 5) | Faz o modo voltar a aparecer depois de compactar ou limpar |
| hook `PreToolUse` (`Read`) | `~/.claude/economia/ler.sh` (timeout 5) | Limita a leitura de arquivo de código longo |
| hook `PostToolUse` (`Bash`) | `~/.claude/economia/aparar.sh` (timeout 10) | Encurta saídas longas de comandos |
| hook `Stop` (opcional, `testes/ganchos/ativar.sh`) | `testes/ganchos/ao-parar.sh` (timeout 180) | Roda a suíte do projeto quando algo mudou |
| `autoMemoryDirectory` (opcional, manual) | `~/memoria` | Uma memória só para todas as pastas |

## Fluxo do modo de economia

```
Claude Code ──JSON──> statusline.sh ──grava──> ~/.claude/economia/uso.json
                          │                         │
                          └─> mostra a barra        └─> modo.sh (hook UserPromptSubmit)
                                                          └─> "Modo de economia: X (...)" na mensagem
```

**statusline.sh**
- Lê do JSON: `model.display_name`, `context_window.used_percentage`, `context_window.total_input_tokens`, `prompt_cache.hit_ratio`,
  `rate_limits.five_hour.used_percentage`, `rate_limits.seven_day.used_percentage`, `cost.total_cost_usd`.
- Grava `uso.json` (`cinco_horas`, `semanal`, `contexto`, `tokens`, `atualizado`) de forma atômica (`.tmp` + `mv`),
  só quando o plano informa os limites.
- Mostra: `[modelo] ctx N% (Xk) · cache N% · 5h N% · semana N% · modo X` (sem limites: custo `$N.NN`).

**modo.sh**
- `modo.sh` → JSON do hook com `hookSpecificOutput.additionalContext`; `modo.sh --so-modo` → só o nome.
- Uso com mais de 900 s (`MAX_IDADE`) = desconhecido → VERDE.
- Maior entre 5 h e semanal decide o modo; contexto ≥ `CONTEXTO_ALTO_TOKENS` (ou ≥ `CONTEXTO_ALTO` % quando não há
  tokens) acrescenta a sugestão de `/clear`/`/compact`.
- Só fala quando o estado (modo + aviso de contexto) muda na sessão: guarda em `sessoes/<session_id>` (apagado após 7 dias).
  `--esquecer` (hook SessionStart) apaga o estado da sessão. `MODO_SEMPRE=1` volta a falar em toda mensagem.
- Os dois scripts usam `export LC_ALL=C` (BUG-001: números com vírgula em pt_BR).

**aparar.sh** (PostToolUse do Bash)
- Saída com mais de `APARAR_LINHAS` linhas: mantém as 40 primeiras, até 40 linhas do meio com erro/aviso
  (`error`, `fail`, `warn`, `traceback`, `denied`…) e as 30 últimas, com o marcador `[camada: N linhas do meio omitidas …]`.
- A íntegra fica em `~/.claude/economia/saidas/` (apagada após 1 dia). Devolve `updatedToolOutput`. `APARAR_LINHAS=0` desliga.

**ler.sh** (PreToolUse do Read)
- Read sem `offset`/`limit`/`allow_large` de arquivo de código com `LER_MIN_LINHAS` ou mais linhas ganha `limit: LER_LIMITE`
  e um aviso com o total de linhas. Não bloqueia nada. `LER_LIMITE=0` desliga.

**limites.conf**
```
AMARELO=50
VERMELHO=80
CONTEXTO_ALTO_TOKENS=120000
CONTEXTO_ALTO=60
APARAR_LINHAS=120
LER_MIN_LINHAS=600
LER_LIMITE=400
```
`MODO_SEMPRE=1` (não vem no arquivo) repete a linha do modo em toda mensagem.

## Instalação (raiz deste repositório)

| Arquivo | Papel |
|---|---|
| `instalar.sh` | Roda a suíte antes (não instala se falhar; `SEM_TESTES=1` evita laço), faz backup em `~/.claude/economia/backup-<data>/`, mescla o `settings.json` com `jq` sem apagar o que existe, copia agentes e scripts, põe as regras no `CLAUDE.md` entre marcadores. Idempotente |
| `desinstalar.sh` | Tira só o que a camada pôs; arquivo só é apagado se idêntico ao instalado (`cmp`); backup continua |
| `claude/` | Cópia de referência do que vai para `~/.claude` |
| `prompt/` | Sistema inteiro em blocos B1–B7 + `montar.sh` + `PROMPT-COMPLETO.md` gerado |
| `testes/` | Suíte, ganchos e registro (ver [04-QUALIDADE](04-QUALIDADE.md)) |

Marcadores no `CLAUDE.md` global: `<!-- camada-economia-tokens:inicio -->` … `<!-- camada-economia-tokens:fim -->`.
Se início ou fim estiverem incompletos, o instalador **recusa** antes de alterar qualquer coisa (BUG-004).

Instalar numa máquina nova:
```bash
sudo apt install jq
cd kit-economia-tokens && ./instalar.sh
```
Depois fechar e abrir o Claude Code.

## Prompt em blocos (`prompt/`)

Cada bloco funciona sozinho; cole só o que a situação pede. Nunca editar o `PROMPT-COMPLETO.md`:
editar o bloco e rodar `prompt/montar.sh`.

| Bloco | Conteúdo | ~tokens |
|---|---|---|
| B1 núcleo | Regras de comportamento econômico (sempre) | 350 |
| B2 modos | VERDE/AMARELO/VERMELHO e a mecânica | 400 |
| B3 subagentes | Definição dos 3 agentes de economia | 270 |
| B4 qualidade | Suíte, registro, hook de testes | 470 |
| B5 processo | Projeto novo até o APROVADO | 290 |
| B6 memória | Memória compartilhada | 450 |
| B7 lições | Armadilhas técnicas | 390 |

| Situação | Comando |
|---|---|
| Conversa rápida sem a camada | `prompt/montar.sh B1` |
| Sessão de trabalho normal | `prompt/montar.sh B1 B2 B6` |
| Mexer em código | `prompt/montar.sh B1 B4 B7` |
| Projeto novo | `prompt/montar.sh B1 B5 B6` |
| Recriar tudo | `cat prompt/PROMPT-COMPLETO.md` |
