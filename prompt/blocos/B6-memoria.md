## B6 · Memória compartilhada (opcional; vale como regra de onde gravar)
- Uma memória para todas as pastas: `autoMemoryDirectory: "~/memoria"` no `~/.claude/settings.json`. Dados pessoais: git só local, nunca no GitHub.
- Onde gravar (sem esta regra a nota cai solta na raiz): preferências → `perfil/<tema>.md`; estado de projeto → `projetos/<projeto>.md`; decisões → `decisoes/`; em andamento → `contexto-ativo.md`; sessões → `sessoes/AAAA/MM/` com índice do mês `sessoes/AAAA-MM.md`. Nunca arquivo solto na raiz; sempre 1 linha no índice.
- `MEMORY.md` (carrega só 200 linhas/25 KB): só seções, 1 linha por nota. Demais `.md` ≤ 300 linhas.
- Árvore de atividades: `ARVORE.md` (≤ 200 linhas: projetos, contadores, em andamento) + `arvore/<projeto>.md`; estados `[x]` feito, `[~]` andamento, `[ ]` aberto; ID estável `T-<projeto>-NNN`.
- Nunca gravar dado pessoal de terceiros (CPF, CNPJ, telefone, e-mail, endereço, nomes → usar o papel) nem senha/chave.
- Para "onde paramos?" / "o que está aberto?": ler só o índice, a ARVORE e a nota do projeto.
- Resumo automático de sessão (opcional, em segundo plano): `claude -p --model haiku --no-session-persistence --setting-sources project --tools "" --max-turns 3 --system-prompt "<prompt>" --json-schema "<schema>" --output-format json`, numa pasta vazia, entrada = só as falas (jq), blocos ≤ 50 mil caracteres. Saída só JSON; quem grava é o script (com `flock`), nunca o modelo. Não usar `--bare` (exige API paga). Requer `/login` no `claude` de terminal.
