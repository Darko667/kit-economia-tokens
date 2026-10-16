# Prompt do sistema de economia de tokens (blocos)

Cada bloco funciona sozinho e encaixa nos outros. Cole só o que a situação pede.
O prompt completo (`PROMPT-COMPLETO.md`, ~3 mil tokens; tamanhos abaixo são estimativas) é gerado a partir dos blocos.
Nunca edite o completo: edite o bloco e rode `prompt/montar.sh`.

| Bloco | Para quê | Quando colar | Tamanho |
|---|---|---|---|
| B1 núcleo | Regras de comportamento econômico | **Sempre** | ~350 tokens |
| B2 modos | VERDE/AMARELO/VERMELHO e como a camada mede o uso | Quando a camada estiver instalada, ou para recriá-la | ~400 |
| B3 subagentes | Definição dos 3 subagentes | Para recriar os agentes ou explicar a delegação | ~270 |
| B4 qualidade | Suíte, registro de bugs e dificuldades, hook de testes | Ao mexer em código com suíte | ~470 |
| B5 processo | Projeto novo: pesquisa → ficha → revisão → validação → APROVADO | Ao começar ou planejar projeto | ~290 |
| B6 memória | Memória compartilhada: onde gravar, índice, árvore | Em qualquer sessão que lê ou grava memória | ~520 |
| B7 lições | Armadilhas técnicas já pagas | Ao escrever scripts Bash, hooks ou instaladores | ~390 |

## Montagens prontas

| Situação | Blocos | Comando |
|---|---|---|
| Conversa rápida, ambiente sem a camada | B1 | `prompt/montar.sh B1` |
| Sessão de trabalho normal | B1 B2 B6 | `prompt/montar.sh B1 B2 B6` |
| Mexer em código de um projeto | B1 B4 B7 | `prompt/montar.sh B1 B4 B7` |
| Começar projeto novo | B1 B5 B6 | `prompt/montar.sh B1 B5 B6` |
| Recriar tudo numa máquina nova | todos | `cat prompt/PROMPT-COMPLETO.md` |

Para copiar direto: `prompt/montar.sh B1 B4 | xclip -selection clipboard` (se tiver o `xclip`).
