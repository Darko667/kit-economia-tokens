# 05 · Memória e processo

## Memória única (opcional, configuração manual)

Sem isso, cada pasta tem sua memória isolada e o contexto se perde entre sessões. Com isso, uma só, enxuta e indexada.
- `autoMemoryDirectory: "~/memoria"` no `~/.claude/settings.json`. Se tiver dados pessoais: git só local,
  nunca no GitHub. O instalador **não** liga isso; é um padrão a adotar.

**Onde gravar** (nunca solto na raiz; toda nota nova ganha 1 linha no `MEMORY.md`, na seção certa):

| Tipo | Pasta |
|---|---|
| Preferência / jeito de trabalhar | `perfil/<tema>.md` |
| Estado de projeto | `projetos/<projeto>.md` |
| Link ou recurso externo | `referencias/<tema>.md` |
| Decisão importante | `decisoes/<tema>.md` |
| Em andamento | `contexto-ativo.md` |
| Sessões | `sessoes/AAAA/MM/` + índice do mês `sessoes/AAAA-MM.md` |

**Por que economiza tokens**
- `MEMORY.md` é o único arquivo carregado sempre (limite real: 200 linhas / 25 KB): só seções, 1 linha por nota.
- O resto só é aberto quando a linha do índice interessa. Demais `.md` ≤ 300 linhas.
- "Onde paramos?" / "o que está aberto?": ler só `MEMORY.md`, `ARVORE.md` e a nota do projeto.
- Antes de criar nota, atualizar a que já cobre o assunto (sem duplicata).

**Árvore de atividades**
- `ARVORE.md` (≤ 200 linhas: projetos, contadores, em andamento) + `arvore/<projeto>.md`.
- Estados `[x]` feito, `[~]` andamento, `[ ]` aberto; ID estável `T-<projeto>-NNN`.
- Concluídas há mais de 30 dias → `arvore/<projeto>-concluidas.md`.
- `arvore/arvore.html` é só de uso interno (sem rede, porta nem CDN).

**Privacidade**: nunca gravar dado pessoal de terceiros (CPF, CNPJ, telefone, e-mail, endereço, nomes de
funcionários → usar o papel) nem senha ou chave.

## Resumo automático de sessão (ideia avançada, não incluída no kit)

Padrão usado com sucesso: ganchos `SessionStart` (varredura de pendentes, mecanismo principal) e
`SessionEnd`/`PreCompact` (disparam o resumo em segundo plano). Adiar no modo VERMELHO.

```bash
CLAUDE_CODE_DISABLE_AUTO_MEMORY=1 claude -p --model haiku \
  --no-session-persistence --setting-sources project --tools "" --max-turns 3 \
  --system-prompt "<prompt>" --json-schema "<schema>" --output-format json
```
- Roda numa pasta vazia, em Haiku, sem ferramentas, com prompt próprio (troca o padrão: menos tokens).
- Entrada = só as falas (filtradas com `jq`): transcrição de 21 MB cai para ~230 mil caracteres;
  blocos ≤ 50 mil caracteres; incremental.
- Saída só JSON (projeto em `enum`, feito, decisões, pendências, tarefas concluídas por ID);
  quem grava é o script, com `flock`, nunca o modelo.
- Não usar `--bare` (exige API paga). Requer `/login` no `claude` de terminal.

## Processo de projeto novo

Planejar antes evita o maior desperdício: código refeito. Nenhum código de projeto novo antes da ficha aprovada.

1. Ideia → **pesquisa** do que já existe (nativo, GitHub; comparar e adaptar).
2. **Entrevista**: 1 rodada por vez, com recomendação; "não sei" vira premissa escrita.
3. `FICHA-DO-PROJETO.md`.
4. **Revisão de qualidade** pelo `revisor-qualidade` (etapa 2b) e de novo após corrigir.
5. **Validação prática** das premissas incertas, em pasta temporária e com custo mínimo.
6. O dono do projeto escreve **APROVADO** → ficha congela (tag `v1-aprovado`) → execução por marcos.

Na execução:
- Não reabrir decisões; decisão pequena → `DECISOES.md`; ideia nova → `IDEIAS-PROXIMA-VERSAO.md` sem implementar.
- Mudança só por `mudancas/PM-NNN.md` (máx. 2 por versão, +20% nos limites).
- Parar e perguntar só se: contradiz a ficha, é irreversível ou mexe em dado real, exige gasto/conta/`sudo`,
  ou estoura limite.
- Cada marco fecha com: testes verdes, `DECISOES.md` em dia, commit em pt-BR (um assunto), demonstração curta.

Projetos já existentes seguem o `CLAUDE.md` próprio; a base vale para eles só numa nova versão com ficha.
