-- Função auxiliar para executar queries em ordem
local function executeQueries(queries, callback)
    local index = 1

    local function executeNextQuery()
        if index > #queries then
            if callback then callback() end
            return
        end

        MySQL.Async.execute(queries[index], {}, function()
            print("Tabela verificada/criada: " .. index)
            index = index + 1
            executeNextQuery()
        end)
    end

    executeNextQuery()
end

-- Função para criar as tabelas no banco de dados
local function createTables()
    local queries = {
        [[
            CREATE TABLE IF NOT EXISTS `mri_qplaylists` (
                `id` INT NOT NULL AUTO_INCREMENT,
                `name` VARCHAR(50) NOT NULL DEFAULT '0',
                `owner` VARCHAR(255) NOT NULL DEFAULT '',
                PRIMARY KEY (`id`)
            ) COLLATE='utf8mb4_general_ci';
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `mri_qsongs` (
                `id` INT NOT NULL AUTO_INCREMENT,
                `url` VARCHAR(50) NOT NULL DEFAULT '0',
                `name` VARCHAR(150) NOT NULL DEFAULT '0',
                `author` VARCHAR(50) NOT NULL DEFAULT '0',
                `maxDuration` INT NOT NULL DEFAULT 0,
                PRIMARY KEY (`id`),
                UNIQUE INDEX `url` (`url`)
            ) COLLATE='utf8mb4_general_ci';
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `mri_qplaylists_users` (
                `id` INT NOT NULL AUTO_INCREMENT,
                `license` VARCHAR(255) NOT NULL DEFAULT '',
                `playlist` INT NOT NULL,
                INDEX `license` (`license`),
                PRIMARY KEY (`id`),
                CONSTRAINT `FK_mri_qplaylists_users_playlist` FOREIGN KEY (`playlist`) REFERENCES `mri_qplaylists` (`id`) ON UPDATE CASCADE ON DELETE CASCADE
            ) COLLATE='utf8mb4_general_ci';
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `mri_qplaylist_songs` (
                `id` INT NOT NULL AUTO_INCREMENT,
                `playlist` INT NOT NULL,
                `song` INT NOT NULL,
                PRIMARY KEY (`id`),
                CONSTRAINT `FK_mri_qplaylist_songs_playlist` FOREIGN KEY (`playlist`) REFERENCES `mri_qplaylists` (`id`) ON UPDATE CASCADE ON DELETE CASCADE,
                CONSTRAINT `FK_mri_qplaylist_songs_song` FOREIGN KEY (`song`) REFERENCES `mri_qsongs` (`id`) ON UPDATE CASCADE ON DELETE CASCADE
            ) COLLATE='utf8mb4_general_ci';
        ]]
    }

    executeQueries(queries, function()
        print("Todas as tabelas foram verificadas/criadas.")
    end)
end

-- Evento que é disparado quando o recurso é iniciado
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print("Recurso " .. resourceName .. " iniciado. Verificando/criando tabelas...")
        createTables()
    end
end)
