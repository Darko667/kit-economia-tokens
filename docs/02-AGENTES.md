# 02 · Agentes

Ficam em `~/.claude/agents/`. Padrão para qualquer subagente sem modelo definido: Haiku
(`env.CLAUDE_CODE_SUBAGENT_MODEL = "haiku"` no `settings.json`).

| Agente | Modelo / esforço | Ferramentas | Usar para |
|---|---|---|---|
| `pesquisador-barato` | haiku / low | Read, Grep, Glob, WebSearch, WebFetch | Buscar em muitos arquivos, ler docs, pesquisar na web, mapear código desconhecido |
| `verificador` | haiku / low | Bash, Read, Grep | Rodar testes, lint, tipos, build e relatar só o que falhou |
| `executor-rotina` | sonnet / medium | todas | Edição já decidida: renomear, ajustar texto, aplicar padrão, teste simples |
| `revisor-qualidade` | opus / high | Read, Grep, Glob, Bash, WebSearch, WebFetch | Revisar `FICHA-DO-PROJETO.md` antes do APROVADO (e de novo após corrigir) |

## pesquisador-barato

- Começa pelo mais barato: Glob e Grep antes de Read; Read só no trecho (offset/limit).
- Para assim que tem a resposta; não explora "por garantia".
- Resposta final ≤ 15 linhas: caminhos com número de linha, trechos ≤ 5 linhas, 1 frase do que achou.
- Se não achar: diz onde procurou em 1 linha e para. Nunca edita arquivos.

## verificador

- Roda o comando pedido (ou o padrão do `CLAUDE.md` do projeto).
- Tudo verde: 1 linha (nº de testes e tempo).
- Falhas: nome do teste ou arquivo:linha + erro em ≤ 5 linhas; no máximo 10, diz quantas ficaram de fora.
- Não corrige nada; não roda o mesmo comando 2×.

## executor-rotina

- Faz exatamente o pedido, no menor número de arquivos.
- Ambíguo ou exige decisão de projeto → para e diz em 1 frase o que falta decidir.
- Final: lista curta de arquivos alterados + 1 linha do que mudou em cada; sem recapitular código.

## revisor-qualidade (setor de qualidade)

Revisa a ficha **antes** do APROVADO, quando corrigir ainda é barato. Só lê e experimenta em pasta temporária;
nunca edita a ficha, nunca aprova, nunca usa `sudo` nem gasta dinheiro.
- Régua: a ficha + o processo de projeto novo (parte 05).
- 11 lições aplicadas a cada ficha: premissa não testada é chute; dados reais ≠ sintéticos (validar em cópia,
  pensar no backlog); falha parcial (tudo ou nada / idempotente); concorrência; segundo plano precisa de canal
  de aviso; custo e cota de toda chamada a modelo/API; entrada hostil (regex, sed, Markdown, HTML, prompt);
  dados pessoais (LGPD); testabilidade sem dado real; limites realistas; instalar/desinstalar seguro.
- Gravidade: **C** (não funciona), **A** (perde dados/quebra/caro), **M**, **B**. Cada achado com evidência e
  correção concreta. Suspeita sem teste = "plausível, não testado".
- Saída (o chamador grava em `REVISAO-FICHA-vN.md`): tabela de achados (≤ ~25), premissas testadas, veredito.
- É o único agente em Opus: o custo se paga porque achar o problema antes do código evita retrabalho
  (lição real: um projeto teve 66 bugs achados depois da aprovação).

## Como delegar barato

- Prompt de agente enxuto e **autocontido** (o agente começa do zero: diga arquivos, objetivo e formato de saída).
- Não reler o que o agente já leu; confiar no resumo e só abrir o trecho citado se precisar.
- Agente que usa navegador: incluir a regra de **fechar cada aba** ao terminar.
- VERMELHO: sem agentes em paralelo.

## Skill de apoio

- `caveman` (opcional, ver parte 06): respostas bem mais curtas. Liga com `/caveman`, desliga com
  "stop caveman" / "normal mode".
