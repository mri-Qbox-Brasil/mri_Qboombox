# mri_Qboombox

Script de boombox para FiveM que permite tocar músicas do YouTube, desenvolvido por Gordela e mantido pela comunidade.

## 📦 Dependências

- [oxmysql](https://github.com/overextended/oxmysql)
- FiveM

## ⚙️ Instalação

1. Adicione este recurso na pasta `resources` do seu servidor
2. Importe o arquivo `database.sql` no seu banco de dados
3. Configure o `Config.lua` conforme necessário

## 🔧 Configuração

Edite o arquivo `Config.lua` para personalizar:

```lua
Config.framework = 'qbcore' -- Opções: qbcore/esx/custom
Config.useItem = false -- Ativar/desativar uso de item
Config.itemName = 'speaker' -- Nome do item (se useItem=true)
Config.timeZone = "America/Sao_Paulo" -- Fuso horário do servidor
```

## 🎮 Como Usar

- Se `useItem = false`, use o comando `/createSpeaker`
- Se `useItem = true`, use o item configurado
- Comandos disponíveis:
  - `/fixSpeakers` - Recarrega todos os alto-falantes

## 📌 Teclas

- `E` (38) - Acessar UI do boombox
- `ENTER` (191) - Posicionar o boombox
- `E` (38) - Mudar animação

## 🤝 Créditos

- Autor original: Gordela
- Mantenedor: Comunidade mri_Qbox

## ❓ Suporte

Discord: https://discord.com/invite/GarJqg77aC
