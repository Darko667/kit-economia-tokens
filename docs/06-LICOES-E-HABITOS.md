# 06 · Lições, hábitos e opcionais

## Lições técnicas (armadilhas já pagas)

- **Locale pt_BR**: `printf '%.0f'` e `sort -g` esperam vírgula → scripts com `export LC_ALL=C`.
  `iconv //TRANSLIT` em locale C vira "?" → `LC_ALL=C.UTF-8 iconv`.
- **jq**: `.command | test()` quebra em hook sem `command` → `(.command // "")`.
- **Desinstalar** só apaga o que for idêntico ao instalado (`cmp`); nunca arquivo do usuário com o mesmo nome.
- **Edição por marcadores**: recusar se início/fim estiverem incompletos, antes de alterar qualquer coisa;
  validar o JSON antes de mexer.
- **`find -newer`** não vê mudança no mesmo tique do relógio → nos testes, marca no passado (`touch -d "-30 sec"`).
- **Instalador que roda testes** chamado por testes → variável de guarda (`SEM_TESTES=1`).
  Testar hook com projeto falso, não com a suíte real.
- **Hook "após Edit/Write"** não vê edição por terminal ou à mão → usar `Stop` + datas de arquivo.
- **`SessionEnd`** tem ~1,5 s e não é garantido em fechamento forçado → só disparar processo destacado
  (`setsid`, `async`) e ter varredura no início da sessão.
- **Login**: o app desktop tem login próprio; processo em segundo plano usa o do `claude` de terminal.
  `claude -p` roda os hooks do usuário, a menos que `--setting-sources project`.
- **`claude -p` barato**: `--system-prompt` troca o prompt padrão (menos tokens); `--json-schema` impõe formato;
  `--no-session-persistence` evita resumir a si mesmo.
- **Transcrição bruta** (21 MB) só com falas cai para ~230 mil caracteres (filtrar `type` user/assistant,
  texto, sem `<…>` de sistema).
- **Contagem de testes**: fixar quando cada contagem rodou e qual versão estava em disco antes de concluir
  que um teste sumiu (D09).
- **Reprodução em cópia**: conferir que o HOME/destino é temporário antes de rodar instalador (D10).
- **Testes e navegador**: subir apps em teste com `--sem-navegador`; fechar cada aba ao terminar.

## Hábitos que valem mais que qualquer ferramenta

1. `/clear` ao trocar de assunto: o contexto antigo é pago de novo a cada mensagem.
2. Pedido específico ("corrige a validação do CPF em validacao.py") gasta muito menos que pedido vago.
3. `/usage` mostra o que mais gastou (skills, subagentes, MCP).
4. MCP que não usa: desligar em `/mcp`.
5. `/model haiku` para tarefa simples; `/model opusplan` só para arquitetura.
6. Documentos grandes (PPTX/XLSX/DOCX/PDF): converter antes para Markdown (ex.: `markitdown`)
   em vez de ler o arquivo bruto.

## Opcionais (não instalados pela camada)

- **caveman global**: `npx skills add juliusbrussee/caveman`.
- **rtk**: encurta saída de git, testes e lint antes de chegar ao Claude (o projeto diz 60%–90% a menos
  nessas saídas). Instalar pelo comando do README de github.com/rtk-ai/rtk e rodar `rtk init -g`.
  Não usar `cargo install rtk` (outro programa com o mesmo nome). Ler o README antes: o hook reescreve comandos.
- **Monitor de uso no terminal**: `uv tool install claude-monitor`.

## Fontes

- Gerenciar custos: https://code.claude.com/docs/en/costs
- Modelo e esforço: https://code.claude.com/docs/en/model-config
- Subagentes: https://code.claude.com/docs/en/sub-agents
- Barra de status: https://code.claude.com/docs/en/statusline
- Hooks: https://code.claude.com/docs/en/hooks
- rtk: https://github.com/rtk-ai/rtk · caveman: https://github.com/juliusbrussee/caveman
