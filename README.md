# mri_Qboombox

<<<<<<< fork
Script de boombox para FiveM que permite tocar músicas do YouTube, desenvolvido por Gordela e mantido pela comunidade.
||||||| base
If you like to use ESX you need to uncomment the line commented in fxmanifest that import esx
=======
## Important Notes
>>>>>>> upstream

<<<<<<< fork
## 📦 Dependências
||||||| base
if the option useItem is activated you need to had the item created in your framework (Config or database) and then use the item to create a boombox
=======
- **Database Setup**:  
  You **need to import the SQL file** into your database. This step is crucial for the resource to work properly.
  
- **Using ESX**:  
  If you want to use **ESX** framework, you will need to **uncomment the line** in the `fxmanifest.lua` file that imports ESX. This allows the resource to interact with the ESX framework.
>>>>>>> upstream

<<<<<<< fork
- [oxmysql](https://github.com/overextended/oxmysql)
- FiveM
||||||| base
If the option useItem is not activated you need to use the command /createSpeaker
=======
- **Using Items**:  
  - **If the option `useItem` is activated** in the configuration, you need to **create the item in your framework (either in the Config file or in the database)**. Once the item is created, you can use it to create a boombox.
  - **If the option `useItem` is not activated**, you can use the command `/createSpeaker` to create a boombox directly.
>>>>>>> upstream

<<<<<<< fork
## ⚙️ Instalação
||||||| base
Any help in https://discord.com/invite/GarJqg77aC
=======
- **Need Help?**  
  If you need further assistance, join the community Discord: [https://discord.com/invite/GarJqg77aC](https://discord.com/invite/GarJqg77aC)
>>>>>>> upstream

<<<<<<< fork
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
||||||| base
Depedencies:
-oxmysql
=======
---

## Dependencies

- `oxmysql`: This is required to interact with the database.

---

## Getting Started: Running the Resource in Development Mode

### Prerequisites

Before you can run the resource, make sure you have the following installed:

1. **Node.js**:  
   Install Node.js from [here](https://nodejs.org). This will allow you to run the development server and build the project.

2. **MySQL Database**:  
   The resource interacts with a MySQL database. Ensure that you have a working database connection and have imported the provided SQL file into your database.

3. **Framework (Optional)**:  
   If you're using the **ESX framework**, ensure you have it installed and properly configured.

### Running the Resource in **development mode**

To start the resource in **development mode**, follow these steps:

1. Clone or download the project.
2. Navigate to the project folder in your terminal.
3. Run the following command to install the necessary dependencies:

   ```bash
   npm install
   ```

4. After the dependencies are installed, run the development server with:

   ```bash
   npm run start
   ```

   This will start the resource in development mode and allow you to see live changes as you make edits.

---

## Building the Resource

To **build** the resource (for production or final deployment), use the following steps:

1. Once you’re ready to build, run the following command:

   ```bash
   npm run build
   ```

   This command compiles the resource and prepares it for production use.

---

## Troubleshooting

- If you have problems related to missing dependencies, try running `npm install` again or delete the `node_modules` folder and reinstall the dependencies.
>>>>>>> upstream
