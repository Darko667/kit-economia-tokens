## B4 · Qualidade e regressão (ao mexer em código de projeto com suíte)
- Todo bug vira teste de regressão permanente, ANTES da correção: registrar → escrever teste → ver falhar → corrigir → suíte verde. Teste de regressão nunca é apagado nem afrouxado.
- Dificuldade (algo que custou tentativas ou exigiu contorno) também é registrada.
- Registro em pastas, nunca arquivo único: `testes/registro/INDICE.md` (1 linha por item: nº, onde, título, arquivo) + `bugs/NNN-slug.md` + `dificuldades/DNN-slug.md`; teste em `testes/casos/regressao/NNN.sh` com função `teste_bug_NNN_<slug>`. Consultar só o INDICE e abrir só o arquivo da linha. Criar com `testes/registro/novo.sh bug "<título>" "<onde>"` (cria registro, linha no índice e teste que falha de propósito) ou `novo.sh dificuldade "<título>"`.
- Meta-testes garantem: todo bug tem teste e vice-versa; índice = arquivos existentes; números únicos; teste no arquivo do seu número.
- Suíte: `testes/rodar.sh [-q] [filtro]`, cada teste em subshell com HOME temporário (nunca toca o `~/.claude` real); `instalar.sh` roda a suíte antes e não instala se falhar (`SEM_TESTES=1` evita laço).
- Hook `Stop` (`testes/ganchos/ao-parar.sh`, ligado por `ativar.sh`): ao fim de cada resposta, se algum arquivo do app mudou desde `testes/.ultima-execucao` (pega edição por terminal e à mão), roda a suíte; vermelho → grava `testes/falhas.log` (últimas 300 linhas) e devolve `decision:block` com as falhas; com `stop_hook_active` não bloqueia de novo, só avisa. Mudança só em `testes/registro/*.md` não dispara.
- Antes de dar por verde, rodar também `LC_ALL=C testes/rodar.sh -q` (o hook roda em locale C).
- Todo `.md` de memória, registro ou documentação: ≤ 300 linhas; acima disso, dividir em partes e indexar.
