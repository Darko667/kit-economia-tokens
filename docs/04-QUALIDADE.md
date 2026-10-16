# 04 · Qualidade e regressão

Por que entra no sistema de tokens: bug que volta custa sessões inteiras de retrabalho, e um registro em
arquivo único obrigava ler tudo a cada consulta (D05). A suíte e o registro em pastas evitam os dois gastos.

## Regras

- **Todo bug vira teste de regressão permanente, antes da correção**:
  registrar → escrever o teste → ver falhar → corrigir → suíte verde. Nunca apagar nem afrouxar teste de regressão.
- **Causa raiz provada**: nenhum bug fica sem causa demonstrada (reproduzir, corrigir, levar à suíte).
- **Dificuldade** (algo que custou tentativas ou exigiu contorno) também é registrada.
- Antes de dar por verde, rodar também em `LC_ALL=C` (o hook roda em locale C).
- Funcionalidade nova ganha teste no arquivo de `testes/casos/` correspondente.
- Afirmação não testada nunca é escrita como fato: testar ou marcar "não verificado".

## Registro em pastas (consulta barata)

```
testes/registro/
  INDICE.md            1 linha por item (nº, onde, título, arquivo) — a única coisa que se lê
  COMO-REGISTRAR.md    passo a passo
  novo.sh              cria registro + linha no índice + teste que falha de propósito
  bugs/NNN-slug.md
  dificuldades/DNN-slug.md
testes/casos/regressao/NNN.sh   função teste_bug_NNN_<slug>
```

```bash
testes/registro/novo.sh bug "<título>" "<onde>"
testes/registro/novo.sh dificuldade "<título>"
```

Meta-testes garantem: todo bug tem teste e vice-versa; índice = arquivos existentes; números únicos;
teste no arquivo do seu número.

## Suíte

- `testes/rodar.sh [-q] [filtro]` (`rodar.sh bug` = só regressão). Cada teste em subshell com **HOME temporário**:
  nunca toca o `~/.claude` real.
- Casos: `instalacao.sh`, `modo.sh`, `statusline.sh`, `gancho.sh`, `registro.sh`, `prompt.sh`, `regressao/`.
- Lint com ShellCheck dentro da suíte; ShellCheck ausente avisa e conta como pulado (BUG-009).
- Estado atual: 61 testes.
- Para economizar contexto, quem roda é o `verificador` (devolve só falhas).

## Hook Stop (testes automáticos)

`testes/ganchos/ao-parar.sh`, ligado por `testes/ganchos/ativar.sh`:
- Ao fim de cada resposta, se algum arquivo do app mudou desde `testes/.ultima-execucao`
  (pega edição por terminal e à mão), roda a suíte.
- Vermelho → grava `testes/falhas.log` (últimas 300 linhas) e devolve `decision: block` com as falhas.
- Com `stop_hook_active` não bloqueia de novo, só avisa (evita laço).
- Mudança só em `testes/registro/*.md` não dispara a suíte.

## Caça ativa a cada marco

Além de rodar o que já está catalogado:
- revisor independente (agente);
- entradas hostis/malformadas geradas (fuzz);
- teste de mutação (plantar defeito e exigir que a suíte falhe);
- execução real numa **cópia** dos dados.
Cada achado: registrar, teste que falha no código antigo, corrigir, suíte verde.

## Bugs já corrigidos (cada um com teste)

| Nº | Onde | Título |
|---|---|---|
| 001 | statusline.sh, modo.sh | Números quebram em locale pt_BR |
| 002 | instalar/desinstalar | Hook sem `command` aborta instalação |
| 003 | desinstalar.sh | Apagava agente do usuário |
| 004 | instalar/desinstalar | Marcador sem fim apagava o resto do CLAUDE.md |
| 005 | registro/novo.sh | Nome errado com acentos em locale C |
| 006 | ganchos/ativar.sh | Apagava o gancho de outro projeto |
| 007 | ganchos/ativar.sh | Gancho com espaço no caminho não rodava |
| 008 | testes/rodar.sh | Lint quebrado e preso aos arquivos de um projeto |
| 009 | testes/rodar.sh | Lint pulado em silêncio |

## Dificuldades registradas

| Nº | Resumo |
|---|---|
| D01 | Testes chamam `instalar.sh`, que roda a suíte → laço infinito (resolvido com `SEM_TESTES=1`) |
| D02 | Hook "após Edit/Write" não vê edição por terminal/à mão → trocado por `Stop` + datas |
| D03 | `find -newer` não via mudança no mesmo tique do relógio |
| D04 | Testar o hook com a suíte real faria a suíte rodar dentro de si mesma |
| D05 | `BUGS.md` único obrigava ler tudo a cada consulta (tokens) → registro em pastas |
| D06 | Suíte verde no terminal e vermelha no hook (locale) |
| D07 | Teste de regressão passou pelo motivo errado |
| D08 | Reescrever o teste gerado pelo `novo.sh` trocou o nome da função |
| D09 | Contagem deu 59 em vez de 60 (causa provada: instalação rodou no meio) |
| D10 | Reprodução numa cópia instalou no `~/.claude` real |
