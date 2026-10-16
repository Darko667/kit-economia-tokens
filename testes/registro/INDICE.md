# Índice de bugs e dificuldades

Leia só esta página e abra apenas o arquivo da linha que interessa. Como registrar: `COMO-REGISTRAR.md`.
Registro novo (não precisa ler nada antes): `testes/registro/novo.sh bug|dificuldade "<título>" "<onde>"`

## Bugs
| Nº | Onde | Título | Arquivo |
|---|---|---|---|
| 001 | `statusline.sh`, `modo.sh` | Barra de status quebra números em locale pt_BR | bugs/001-locale-pt-br.md |
| 002 | `instalar.sh`, `desinstalar.sh` | Hook sem `command` aborta instalação | bugs/002-hook-sem-command.md |
| 003 | `desinstalar.sh` | Desinstalar apaga agente do usuário | bugs/003-desinstalar-apaga-agente.md |
| 004 | `instalar.sh`, `desinstalar.sh` | Marcador sem fim apaga o resto do CLAUDE.md | bugs/004-marcador-incompleto.md |
| 005 | testes/registro/novo.sh | novo.sh gera nome errado com acentos em locale C | bugs/005-novo-sh-gera-nome-errado-com-acentos-em.md |
| 006 | testes/ganchos/ativar.sh | ativar.sh apaga o gancho de outro projeto | bugs/006-ativar-sh-apaga-o-gancho-de-outro-projet.md |
| 007 | testes/ganchos/ativar.sh | gancho com espaço no caminho não roda | bugs/007-gancho-com-espaco-no-caminho-nao-roda.md |
| 008 | testes/rodar.sh | lint do rodar.sh quebrado e preso aos arquivos de um projeto | bugs/008-lint-do-rodar-sh-quebrado-e-preso-aos-ar.md |
| 009 | testes/rodar.sh | lint pulado em silêncio | bugs/009-lint-pulado-em-silencio.md |

## Dificuldades
| Nº | Título | Arquivo |
|---|---|---|
| D01 | Testes chamam `instalar.sh`, que roda a suíte, que chama `instalar.sh` (laço infinito) | dificuldades/D01-laco-instalar-testes.md |
| D02 | Hook "após Edit/Write" não vê mudanças feitas por comando no terminal nem à mão | dificuldades/D02-hook-edit-nao-ve-terminal.md |
| D03 | Nos testes do hook, marca de tempo e edição caíam no mesmo instante do relógio e o `find -newer` não via a mudança | dificuldades/D03-find-newer-mesmo-instante.md |
| D04 | Testar o hook com a suíte real faria a suíte rodar dentro de si mesma | dificuldades/D04-suite-dentro-da-suite.md |
| D05 | Um BUGS.md único obrigava ler o arquivo inteiro a cada consulta (tokens) | dificuldades/D05-registro-unico-caro.md |
| D06 | Suíte verde no terminal e vermelha no hook (locale diferente) | dificuldades/D06-suite-verde-no-terminal-e-vermelha-no-ho.md |
| D07 | Teste de regressão passou pelo motivo errado | dificuldades/D07-teste-de-regressao-passou-pelo-motivo-er.md |
| D08 | Reescrever o teste gerado pelo novo.sh trocou o nome da função | dificuldades/D08-reescrever-o-teste-gerado-pelo-novo-sh-t.md |
| D09 | Contagem da suíte deu 59 em vez de 60 uma vez, sem reproduzir | dificuldades/D09-contagem-da-suite-deu-59-em-vez-de-60-um.md |
| D10 | Reprodução numa cópia instalou no ~/.claude real | dificuldades/D10-reproducao-numa-copia-instalou-no-claude.md |
