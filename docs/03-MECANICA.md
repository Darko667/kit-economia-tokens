# 03 · Mecânica (como a camada funciona por dentro)

## settings.json (`~/.claude/settings.json`)

| Chave | Valor | Efeito |
|---|---|---|
| `model` | `sonnet` | Conversa principal sai do Opus por padrão |
| `effortLevel` | `medium` | Menos raciocínio gasto em tarefa simples |
| `env.CLAUDE_CODE_SUBAGENT_MODEL` | `haiku` | Subagentes no modelo mais barato |
| `statusLine` | `~/.claude/economia/statusline.sh` | Barra de status + medição do uso |
| hook `UserPromptSubmit` | `~/.claude/economia/modo.sh` (timeout 5) | Injeta o modo em cada mensagem |
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
- Lê do JSON: `model.display_name`, `context_window.used_percentage`,
  `rate_limits.five_hour.used_percentage`, `rate_limits.seven_day.used_percentage`, `cost.total_cost_usd`.
- Grava `uso.json` (`cinco_horas`, `semanal`, `contexto`, `atualizado`) de forma atômica (`.tmp` + `mv`),
  só quando o plano informa os limites.
- Mostra: `[modelo] ctx N% · 5h N% · semana N% · modo X` (sem limites: custo `$N.NN`).

**modo.sh**
- `modo.sh` → JSON do hook com `hookSpecificOutput.additionalContext`; `modo.sh --so-modo` → só o nome.
- Uso com mais de 900 s (`MAX_IDADE`) = desconhecido → VERDE.
- Maior entre 5 h e semanal decide o modo; contexto ≥ `CONTEXTO_ALTO` acrescenta a sugestão de `/clear`/`/compact`.
- Os dois scripts usam `export LC_ALL=C` (BUG-001: números com vírgula em pt_BR).

**limites.conf**
```
AMARELO=50
VERMELHO=80
CONTEXTO_ALTO=60
```

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
