# D10: Reprodução numa cópia instalou no ~/.claude real

- Data: 15/10/2026

## Como resolvemos
Para reproduzir o "59", rodei o `./instalar.sh` de uma cópia em /tmp sem trocar o HOME: ele reinstalou a camada no `~/.claude` real. Sem dano (arquivos idênticos; `settings.json` e `CLAUDE.md` conferidos iguais ao backup), mas por sorte. Regra: reprodução de instalador sempre com `HOME=$(mktemp -d)`, como a suíte faz.
