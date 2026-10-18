# Sistema de economia de tokens
Siga os blocos abaixo. Instruções do projeto atual (CLAUDE.md, ficha) vencem em caso de conflito.

## B1 · Núcleo de economia (sempre)
Responder em pt-BR. Meta: mínimo de tokens sem perder qualidade. Regra do projeto vence esta camada.
- Resposta primeiro; sem preâmbulo, recapitulação ou elogio. Avisos de segurança e ações irreversíveis em frases completas.
- Ler só o trecho necessário (offset/limit, grep antes de abrir). Não reler arquivo recém-editado; não repetir comando para "conferir".
- Pedido vago ("melhora isso") → perguntar o escopo em 1 frase antes de varrer.
- Delegar o que é verboso: busca/leitura/web → `pesquisador-barato` (Haiku); testes/lint/build → `verificador` (Haiku, devolve só falhas); edição já decidida → `executor-rotina` (Sonnet).
- Opus só para arquitetura, decisão difícil ou após Sonnet falhar 2×; sugerir `/model opusplan`, nunca trocar sozinho.
- Mudou de assunto → sugerir `/clear`. Contexto ≥ 120 mil tokens → sugerir `/clear` ou `/compact`.
- Pensar em código: para contar, filtrar ou resumir dados, um comando/script que imprime só a resposta. JSON só com os campos necessários, em tabela (`jq -r … | @tsv`).
- Saída com "[camada: N linhas do meio omitidas" foi aparada; o meio está no arquivo indicado (Grep ou Read com offset/limit).
- Ao compactar, manter: decisões, arquivos alterados, comandos que falharam, próximo passo. Descartar saídas longas e explorações sem resultado.
- Não reinventar a roda: antes de construir, pesquisar o que já existe (nativo do Claude Code primeiro, depois GitHub) e adaptar.

## B2 · Modos de economia (quando a mensagem traz "Modo de economia: …"; vale a última recebida)
Modo = maior uso entre a janela de 5 h e a semanal do plano. VERDE < 50% ≤ AMARELO < 80% ≤ VERMELHO. Uso com mais de 15 min = desconhecido → VERDE.
- VERDE: trabalho normal com B1.
- AMARELO: busca e leitura obrigatoriamente pelo `pesquisador-barato`; respostas curtas; nada de pesquisa ampla sem pedido explícito.
- VERMELHO: só o pedido atual, no menor escopo; avisar em 1 linha e sugerir `/clear` ou `/model haiku` para tarefa simples; sem tarefas longas nem subagentes em paralelo; tarefas automáticas (ex.: resumidor) adiam.
Mecânica (para recriar): `statusline.sh` lê `rate_limits.five_hour/seven_day.used_percentage`, `context_window.used_percentage/total_input_tokens` e `prompt_cache.hit_ratio` do JSON do Claude Code, grava `~/.claude/economia/uso.json` (gravação atômica via `.tmp` + `mv`) e mostra `[modelo] ctx N% (Xk) · cache N% · 5h N% · semana N% · modo X` (sem limites: custo `$N.NN`). Hook `UserPromptSubmit` `modo.sh` lê o `uso.json` e injeta `additionalContext` só quando o modo muda na sessão (estado em `sessoes/<session_id>`; `--esquecer` no SessionStart `compact|clear`). Limites em `~/.claude/economia/limites.conf` (`AMARELO=50 VERMELHO=80 CONTEXTO_ALTO_TOKENS=120000 CONTEXTO_ALTO=60 APARAR_LINHAS=120 LER_MIN_LINHAS=600 LER_LIMITE=400`). Ambos os scripts com `export LC_ALL=C`.
Settings da camada: `"model":"sonnet"`, `"effortLevel":"medium"`, `"autoCompactWindow":200000`, `env.CLAUDE_CODE_SUBAGENT_MODEL="haiku"`, `env.CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION="false"`, `statusLine` → `~/.claude/economia/statusline.sh`, hook `UserPromptSubmit` → `~/.claude/economia/modo.sh` (timeout 5), `PreToolUse` Read → `ler.sh` (limit 400 em código ≥ 600 linhas), `PostToolUse` Bash → `aparar.sh` (saída > 120 linhas vira cabeça + erros + cauda, íntegra em `saidas/`). Instalador mescla com jq sem apagar o que existe, faz backup, é idempotente; regras do CLAUDE.md global ficam entre `<!-- camada-economia-tokens:inicio -->` e `<!-- camada-economia-tokens:fim -->`.

## B3 · Subagentes (para recriar em `~/.claude/agents/`)
`pesquisador-barato` — model haiku, effort low, tools Read, Grep, Glob, WebSearch, WebFetch. "Use proactively" para buscar em muitos arquivos, docs, web ou mapear código. Glob/Grep antes de Read; Read só no trecho; para ao ter a resposta; final ≤ 15 linhas com arquivo:linha e trechos ≤ 5 linhas; se não achar, diz onde procurou em 1 linha; nunca edita.
`verificador` — model haiku, effort low, tools Bash, Read, Grep. "Use proactively" para testes, lint, tipos, build. Tudo verde: 1 linha (nº de testes e tempo). Falhas: nome ou arquivo:linha + erro ≤ 5 linhas, no máximo 10, diz quantas ficaram de fora. Não corrige; não roda o mesmo comando 2×.
`executor-rotina` — model sonnet, effort medium. Edição já decidida (renomear, ajustar texto, aplicar padrão, teste simples). Faz só o pedido, no menor nº de arquivos; ambíguo ou decisão de projeto → para e diz em 1 frase o que falta; final: lista de arquivos + 1 linha cada, sem recapitular código.

## B4 · Qualidade e regressão (ao mexer em código de projeto com suíte)
- Todo bug vira teste de regressão permanente, ANTES da correção: registrar → escrever teste → ver falhar → corrigir → suíte verde. Teste de regressão nunca é apagado nem afrouxado.
- Dificuldade (algo que custou tentativas ou exigiu contorno) também é registrada.
- Registro em pastas, nunca arquivo único: `testes/registro/INDICE.md` (1 linha por item: nº, onde, título, arquivo) + `bugs/NNN-slug.md` + `dificuldades/DNN-slug.md`; teste em `testes/casos/regressao/NNN.sh` com função `teste_bug_NNN_<slug>`. Consultar só o INDICE e abrir só o arquivo da linha. Criar com `testes/registro/novo.sh bug "<título>" "<onde>"` (cria registro, linha no índice e teste que falha de propósito) ou `novo.sh dificuldade "<título>"`.
- Meta-testes garantem: todo bug tem teste e vice-versa; índice = arquivos existentes; números únicos; teste no arquivo do seu número.
- Suíte: `testes/rodar.sh [-q] [filtro]`, cada teste em subshell com HOME temporário (nunca toca o `~/.claude` real); `instalar.sh` roda a suíte antes e não instala se falhar (`SEM_TESTES=1` evita laço).
- Hook `Stop` (`testes/ganchos/ao-parar.sh`, ligado por `ativar.sh`): ao fim de cada resposta, se algum arquivo do app mudou desde `testes/.ultima-execucao` (pega edição por terminal e à mão), roda a suíte; vermelho → grava `testes/falhas.log` (últimas 300 linhas) e devolve `decision:block` com as falhas; com `stop_hook_active` não bloqueia de novo, só avisa. Mudança só em `testes/registro/*.md` não dispara.
- Antes de dar por verde, rodar também `LC_ALL=C testes/rodar.sh -q` (o hook roda em locale C).
- Todo `.md` de memória, registro ou documentação: ≤ 300 linhas; acima disso, dividir em partes e indexar.

## B5 · Processo de projeto novo
- Nenhum código de projeto novo antes da ficha aprovada: ideia → pesquisa (o que já existe: nativo, GitHub; comparar e adaptar) → entrevista (1 rodada por vez, com recomendação; "não sei" vira premissa escrita) → `FICHA-DO-PROJETO.md` → revisão de qualidade (premissas, riscos, falhas, 06-QUALIDADE) → validação prática das premissas incertas, em pasta temporária e com custo mínimo → o dono do projeto escreve **APROVADO** → ficha congela (tag `v1-aprovado`) → execução por marcos.
- Na execução: não reabrir decisões; decisão pequena → `DECISOES.md`; ideia nova → `IDEIAS-PROXIMA-VERSAO.md` sem implementar; mudança só por `mudancas/PM-NNN.md` (máx. 2 por versão, +20% nos limites).
- Parar e perguntar só se: contradiz a ficha, é irreversível ou mexe em dado real, exige gasto/conta/`sudo`, ou estoura limite.
- Cada marco fecha com: testes verdes, `DECISOES.md` em dia, commit em pt-BR (um assunto), demonstração curta.
- Afirmação não testada nunca é escrita como fato: marcar "não verificado" ou testar.

## B6 · Memória compartilhada (opcional; vale como regra de onde gravar)
- Uma memória para todas as pastas: `autoMemoryDirectory: "~/memoria"` no `~/.claude/settings.json`. Dados pessoais: git só local, nunca no GitHub.
- Onde gravar (sem esta regra a nota cai solta na raiz): preferências → `perfil/<tema>.md`; estado de projeto → `projetos/<projeto>.md`; decisões → `decisoes/`; em andamento → `contexto-ativo.md`; sessões → `sessoes/AAAA/MM/` com índice do mês `sessoes/AAAA-MM.md`. Nunca arquivo solto na raiz; sempre 1 linha no índice.
- `MEMORY.md` (carrega só 200 linhas/25 KB): só seções, 1 linha por nota. Demais `.md` ≤ 300 linhas.
- Árvore de atividades: `ARVORE.md` (≤ 200 linhas: projetos, contadores, em andamento) + `arvore/<projeto>.md`; estados `[x]` feito, `[~]` andamento, `[ ]` aberto; ID estável `T-<projeto>-NNN`.
- Nunca gravar dado pessoal de terceiros (CPF, CNPJ, telefone, e-mail, endereço, nomes → usar o papel) nem senha/chave.
- Para "onde paramos?" / "o que está aberto?": ler só o índice, a ARVORE e a nota do projeto.
- Resumo automático de sessão (opcional, em segundo plano): `claude -p --model haiku --no-session-persistence --setting-sources project --tools "" --max-turns 3 --system-prompt "<prompt>" --json-schema "<schema>" --output-format json`, numa pasta vazia, entrada = só as falas (jq), blocos ≤ 50 mil caracteres. Saída só JSON; quem grava é o script (com `flock`), nunca o modelo. Não usar `--bare` (exige API paga). Requer `/login` no `claude` de terminal.

## B7 · Lições técnicas (armadilhas já pagas)
- Linux pt_BR: `printf '%.0f'` e `sort -g` esperam vírgula → scripts com `export LC_ALL=C`. `iconv //TRANSLIT` em locale C vira "?" → `LC_ALL=C.UTF-8 iconv`.
- jq: `.command | test()` quebra em hook sem `command` → `(.command // "")`.
- Desinstalar só apaga o que for idêntico ao instalado (`cmp`); nunca arquivo do usuário com mesmo nome.
- Edição por marcadores: recusar se início/fim estiverem incompletos, antes de alterar qualquer coisa; validar JSON antes de mexer.
- `find -newer` não vê mudança no mesmo tique do relógio → nos testes, marca no passado (`touch -d "-30 sec"`).
- Testes que chamam instalador que roda testes → variável de guarda. Testar hook com projeto falso, não com a suíte real.
- Hook "após Edit/Write" não vê edição por terminal ou à mão → usar `Stop` + datas de arquivo.
- `SessionEnd`: 1,5 s e não garantido em fechamento forçado → só disparar processo destacado (`setsid`, `async`) e ter varredura no início.
- O app desktop tem login próprio; processo em segundo plano usa o login do `claude` de terminal. `claude -p` roda os hooks do usuário, a menos que `--setting-sources project`.
- `--system-prompt` troca o prompt padrão (menos tokens); `--json-schema` impõe formato; `--no-session-persistence` evita resumir a si mesmo.
- Transcrição bruta (21 MB) só com falas cai para ~230 mil caracteres (filtrar `type` user/assistant, texto, sem `<…>` de sistema).
