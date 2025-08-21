Speakers = {}
local objects = {}

function SufficientDistance(coords)
    local minDistance = true
    for k,v in pairs(Speakers) do
        local dist = #(coords - v.coords)
        if dist <= 2 and not v.permaDisabled then
            minDistance = false
        end
    end
    return minDistance
end

RegisterNetEvent('mri_Qboombox:server:Playsong', function(data)
    if data and data.repro and tonumber(data.repro) and Speakers[tonumber(data.repro + 1)] then
        local v = Speakers[tonumber(data.repro + 1)]
        local songId = GetSongInfo(data.playlist, data.url)
        v.maxDuration = data.playlist.songs[songId].maxDuration
        v.url = data.url
        v.time = data.time
        v.playlistPLaying = data.playlist
        v.isPlaying = false
        v.paused = false
        v.pausedTime = 0
        v.songId = songId
        TriggerClientEvent('mri_Qboombox:client:updateBoombox', -1, tonumber(data.repro + 1), v)
    end
end)

RegisterNetEvent('mri_Qboombox:server:SyncNewVolume', function(data)
    if data and data.repro and tonumber(data.repro) and Speakers[tonumber(data.repro + 1)] then
        local v = Speakers[tonumber(data.repro + 1)]
        v.volume = data.volume
        TriggerClientEvent('mri_Qboombox:client:updateVolume', -1, tonumber(data.repro + 1), v.volume)
    end
end)

RegisterNetEvent('mri_Qboombox:server:SyncNewDist', function(data)
    if data and data.repro and tonumber(data.repro) and Speakers[tonumber(data.repro + 1)] then
        local v = Speakers[tonumber(data.repro + 1)]
        if data.dist > 50 then
            data.dist = 50
        elseif data.dist < 2 then
            data.dist = 2
        end
        v.maxDistance = data.dist
        TriggerClientEvent('mri_Qboombox:client:updateDist', -1, tonumber(data.repro + 1), v.maxDistance)
    end
end)

RegisterNetEvent('mri_Qboombox:server:deleteBoombox', function(id, x)
    local src = source
    if Speakers[id] and Speakers[id].coords and Speakers[id].coords.x and Speakers[id].coords.x == x and not Speakers[id].permaDisabled then
        Speakers[id].permaDisabled = true
        Speakers[id].playlistPLaying = {}
        Speakers[id].url = ''
        if objects[id] and objects[id] ~= -1 and DoesEntityExist(objects[id]) then
            DeleteEntity(objects[id])
        end
        objects[id] = -1
        TriggerClientEvent('mri_Qboombox:client:deleteBoombox', -1, id)
        if Config.useItem then
            AddItem(src)
        end
    end
end)

function GetSongInfo(playlist, url)
    if playlist.songs then
        for k,v in pairs(playlist.songs) do
            if v.url == url then
                return k
            end
        end
    else
        return -1
    end
end

Citizen.CreateThread(function()
    while true do
        local sleep = 10000
        local time = os.time() * 1000
        for k,v in pairs(Speakers) do
            if v.playlistPLaying.songs and not v.permaDisabled then
                local nextSong = (v.time + v.maxDuration * 1000) - time
                if sleep > nextSong then
                    sleep = nextSong
                end
                if nextSong <= 0 then
                    if v.playlistPLaying.songs[v.songId + 1] then
                        v.url = v.playlistPLaying.songs[v.songId + 1].url
                        v.time = os.time() * 1000
                        v.isPlaying = false
                        v.songId = v.songId + 1
                        v.maxDuration = v.playlistPLaying.songs[v.songId].maxDuration
                        TriggerClientEvent('mri_Qboombox:client:updateBoombox', -1, k, v)
                    else
                        v.url = v.playlistPLaying.songs[1].url
                        v.time = os.time() * 1000
                        v.isPlaying = false
                        v.songId = 1
                        v.maxDuration = v.playlistPLaying.songs[1].maxDuration
                        TriggerClientEvent('mri_Qboombox:client:updateBoombox', -1, k, v)
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

CreateCallback("mri_Qboombox:callback:getBoomboxs", function(source, cb)
	cb(Speakers)
end)

function ExistPlaylist(playlists, playlistId)
    for k,v in pairs(playlists) do
        if v.id == playlistId then
            return k
        end
    end
    return - 1
end

CreateCallback("mri_Qboombox:callback:getPlaylists", function(source, cb)
    local license = GetPlayerIdentifierByType(source, 'license')
    MySQL.Async.fetchAll("SELECT mri_qplaylists.id AS playlistId, mri_qplaylist_songs.id AS songIdInPlaylist, mri_qplaylists.name AS PlaylistName, mri_qsongs.url, mri_qsongs.name, mri_qsongs.author, mri_qsongs.maxDuration FROM mri_qplaylists_users LEFT JOIN mri_qplaylist_songs ON mri_qplaylists_users.playlist = mri_qplaylist_songs.playlist LEFT JOIN mri_qplaylists ON mri_qplaylists_users.playlist = mri_qplaylists.id LEFT JOIN mri_qsongs ON mri_qplaylist_songs.song = mri_qsongs.id WHERE license = @license", {['@license'] = license}, function(results)        local playlists = {}
        for k,v in pairs(results) do
            local ExistPlaylist = ExistPlaylist(playlists, v.playlistId)
            if ExistPlaylist ~= -1 then
                table.insert(playlists[ExistPlaylist].songs, {id = v.songIdInPlaylist, url = v.url, name = v.name, author = v.author, maxDuration = v.maxDuration})
            else
                if v.songIdInPlaylist then
                    table.insert(playlists, {id = v.playlistId, name = v.PlaylistName, songs = {{id = v.songIdInPlaylist, url = v.url, name = v.name, author = v.author, maxDuration = v.maxDuration}}})
                else
                    table.insert(playlists, {id = v.playlistId, name = v.PlaylistName, songs = {}})
                end
            end
        end
        cb(playlists)
    end)
end)

CreateCallback("mri_Qboombox:callback:getNewPlaylist", function(source, cb, data)
    local license = GetPlayerIdentifierByType(source, 'license')
    if data == '' then
        data = Config.Translations.newPlaylist
    end
    local idPlaylist = MySQL.insert.await('INSERT INTO mri_qplaylists (name, owner) VALUES (?, ?)', {
        data,
        license
    })
    local idPlaylistUser = MySQL.insert.await('INSERT INTO mri_qplaylists_users (playlist, license) VALUES (?, ?)', {
        idPlaylist,
        license
    })
    cb(idPlaylist)
end)

RegisterNetEvent('mri_Qboombox:server:addSong', function(data)
    local src = source
    MySQL.Async.fetchAll("SELECT id FROM mri_qsongs WHERE url = @url", {['@url'] = data.url}, function(results)
        if results[1] and results[1].id then
            local idSongInPlaylist = MySQL.insert.await('INSERT INTO mri_qplaylist_songs (playlist, song) VALUES (?, ?)', {
                data.playlistActive,
                results[1].id
            })
            TriggerClientEvent('mri_Qboombox:client:resyncPlaylists', src)
        else
            local idSong = MySQL.insert.await('INSERT INTO mri_qsongs (url, maxDuration, name, author) VALUES (?, ?, ?, ?)', {
                data.url,
                data.maxDuration,
                data.name,
                data.author
            })
            local idSongInPlaylist = MySQL.insert.await('INSERT INTO mri_qplaylist_songs (playlist, song) VALUES (?, ?)', {
                data.playlistActive,
                idSong
            })
            TriggerClientEvent('mri_Qboombox:client:resyncPlaylists', src)
        end
    end)
end)

RegisterNetEvent('mri_Qboombox:server:deletePlayList', function(data)
    local src = source
    local license = GetPlayerIdentifierByType(src, 'license')
    MySQL.query('DELETE FROM mri_qplaylists_users WHERE playlist = ? and license = ?', { data, license }, function()
        TriggerClientEvent('mri_Qboombox:client:resyncPlaylists', src)
    end)
end)

RegisterNetEvent('mri_Qboombox:server:importNewPlaylist', function(data)
    local src = source
    local license = GetPlayerIdentifierByType(src, 'license')
    MySQL.Async.fetchAll("SELECT id FROM mri_qplaylists_users WHERE playlist = @playlist and license = @license", {['@playlist'] = tonumber(data), ['@license'] = license}, function(results)
        if #results < 1 then
            local id = MySQL.insert.await('INSERT INTO mri_qplaylists_users (license, playlist) VALUES (?, ?)', {
                license,
                data
            })
            if id then
                TriggerClientEvent('mri_Qboombox:client:resyncPlaylists', src)
            end
        end
    end)
end)

RegisterNetEvent('mri_Qboombox:server:deleteSongPlaylist', function(data)
    local src = source
    local license = GetPlayerIdentifierByType(src, 'license')
    MySQL.Async.fetchAll("SELECT owner FROM mri_qplaylists WHERE id = @playlist", {['@playlist'] = tonumber(data.playlist)}, function(results)
        if results[1].owner == license then
            MySQL.query('DELETE FROM mri_qplaylist_songs WHERE id = ? and playlist = ?', { data.songId, data.playlist }, function()
                TriggerClientEvent('mri_Qboombox:client:resyncPlaylists', src)
            end)
        end
    end)
end)

RegisterNetEvent('mri_Qboombox:server:nextSong', function(data)
    if data and data.repro and tonumber(data.repro) and Speakers[tonumber(data.repro + 1)] then
        local v = Speakers[tonumber(data.repro + 1)]
        local songId = GetSongInfo(v.playlistPLaying, v.url)
        if v.playlistPLaying.songs[songId + 1] then
            songId = songId + 1
            v.maxDuration = v.playlistPLaying.songs[songId].maxDuration
            v.url = v.playlistPLaying.songs[songId].url
            v.time = data.time
            v.isPlaying = false
            v.songId = songId
            v.paused = false
            v.pausedTime = 0
        else
            if v.playlistPLaying.songs[1] then
                v.maxDuration = v.playlistPLaying.songs[1].maxDuration
                v.url = v.playlistPLaying.songs[1].url
                v.time = data.time
                v.isPlaying = false
                v.songId = 1
                v.paused = false
                v.pausedTime = 0
            end
        end
        TriggerClientEvent('mri_Qboombox:client:updateBoombox', -1, tonumber(data.repro + 1), v)
    end
end)

RegisterNetEvent('mri_Qboombox:server:prevSong', function(data)
    if data and data.repro and tonumber(data.repro) and Speakers[tonumber(data.repro + 1)] then
        local v = Speakers[tonumber(data.repro + 1)]
        local songId = GetSongInfo(v.playlistPLaying, v.url)
        if v.playlistPLaying.songs[songId - 1] then
            songId = songId - 1
            v.maxDuration = v.playlistPLaying.songs[songId].maxDuration
            v.url = v.playlistPLaying.songs[songId].url
            v.time = data.time
            v.isPlaying = false
            v.songId = songId
            v.paused = false
            v.pausedTime = 0
        else
            if v.playlistPLaying.songs[#v.playlistPLaying.songs] then
                v.maxDuration = v.playlistPLaying.songs[#v.playlistPLaying.songs].maxDuration
                v.url = v.playlistPLaying.songs[#v.playlistPLaying.songs].url
                v.time = data.time
                v.isPlaying = false
                v.songId = #v.playlistPLaying.songs
                v.paused = false
                v.pausedTime = 0
            end
        end
        TriggerClientEvent('mri_Qboombox:client:updateBoombox', -1, tonumber(data.repro + 1), v)
    end
end)

RegisterNetEvent('mri_Qboombox:server:syncNewTime', function(data)
    if data and data.repro and tonumber(data.repro) and Speakers[tonumber(data.repro + 1)] then
        local v = Speakers[tonumber(data.repro + 1)]
        v.time = data.time
        TriggerClientEvent('mri_Qboombox:client:updateBoombox', -1, tonumber(data.repro + 1), v)
    end
end)

RegisterNetEvent('mri_Qboombox:server:pauseSong', function(data)
    if data and data.repro and tonumber(data.repro) and Speakers[tonumber(data.repro + 1)] then
        local v = Speakers[tonumber(data.repro + 1)]
        if not v.paused then
            v.paused = true
            v.pausedTime = data.value
        else
            v.paused = false
            v.time = data.time - (v.pausedTime * 1000)
        end
        TriggerClientEvent('mri_Qboombox:client:updateBoombox', -1, tonumber(data.repro + 1), v)
    end
end)

function CreateSpeaker(src)
    local enoughDistance = SufficientDistance(GetEntityCoords(GetPlayerPed(src)))
    if enoughDistance then
        local data = {volume = 50, url = '', coords = GetEntityCoords(GetPlayerPed(src)), playlistPLaying = {}, time = 0, maxDistance = 15, isPlaying = false, maxDuration = 5000000, songId = -2, permaDisabled = false, paused = false, pausedTime = 0, isMoving = false, playerMoving = -2}
        table.insert(Speakers, data)
        if Config.useItem then
            DeleteItem(src)
        end
        TriggerClientEvent('mri_Qboombox:client:doAnim', src)
        Citizen.Wait(1000)
        local obj = CreateObject(Config.RadioProp, data.coords - vector3(0.0, 0.0, 1.0), true, false, true)
        table.insert(objects, obj)
        TriggerClientEvent('mri_Qboombox:client:insertSpeaker', -1, data)
    else
        TriggerClientEvent('mri_Qboombox:client:notify', src, Config.Translations.notEnoughDistance)
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    for k,v in pairs(objects) do
        if v ~= -1 and DoesEntityExist(v) then
            DeleteEntity(v)
        end
    end
end)

CreateCallback("mri_Qboombox:callback:canMove", function(source, cb, id)
    local src = source
    if not Speakers[id].isMoving then
        Speakers[id].isMoving = true
        Speakers[id].playerMoving = src
        if objects[id] and objects[id] ~= -1 and DoesEntityExist(objects[id]) then
            DeleteEntity(objects[id])
        end
        objects[id] = -1
        TriggerClientEvent('mri_Qboombox:client:updatePlayerMoving', -1, id, src)
    end
    cb(Speakers[id].isMoving)
end)

RegisterNetEvent('mri_Qboombox:server:updateObjectCoords', function(id)
    local src = source
    if Speakers[id].isMoving and Speakers[id].playerMoving == src then
        local coords = GetEntityCoords(GetPlayerPed(src))
        local obj = CreateObject(Config.RadioProp, coords - vector3(0.0, 0.0, 1.0), true, false, true)
        objects[id] = obj
        Speakers[id].isMoving = false
        Speakers[id].coords = coords
        Speakers[id].playerMoving = -1
        TriggerClientEvent('mri_Qboombox:client:syncLastCoords', -1, id, coords)
    end
end)

----- SERVER ----- 
RegisterNetEvent('mri_Qboombox:server:createVehicleSpeaker', function(data)
    local src = source
    local enoughDistance = SufficientDistance(data.coords)
    if enoughDistance then
        table.insert(Speakers, data)
        TriggerClientEvent('mri_Qboombox:client:insertSpeaker', -1, data)
    else
        TriggerClientEvent('mri_Qboombox:client:notify', src, Config.Translations.notEnoughDistance)
    end
end)


-- Função para verificar se um objeto de rede ainda existe
local function doesNetworkObjectExist(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    return DoesEntityExist(entity)
end

-- Evento para remover um alto-falante quando o objeto de rede não existe mais
RegisterNetEvent('mri_Qboombox:server:removeInvalidSpeaker', function(id)
    if Speakers[id] then
        -- Remove o alto-falante da tabela
        Speakers[id] = nil
        -- Sincroniza a remoção com todos os clientes
        TriggerClientEvent('mri_Qboombox:client:deleteBoombox', -1, id)
    end
end)

-- Verificação periódica para remover alto-falantes inválidos
Citizen.CreateThread(function()
    while true do
        for id, speaker in pairs(Speakers) do
            -- Verifica se o alto-falante está vinculado a um veículo
            if speaker.isVehicleSpeaker and speaker.vehicle then
                -- Verifica se o veículo ainda existe
                if not doesNetworkObjectExist(speaker.vehicle) then
                    -- Remove o alto-falante inválido
                    TriggerEvent('mri_Qboombox:server:removeInvalidSpeaker', id)
                end
            end
        end
        Citizen.Wait(5000) -- Verifica a cada 5 segundos
    end
end)

-- pega a localização do jogador com a caixa andando
RegisterNetEvent('mri_Qboombox:server:syncMovingCoords', function(id, coords)
    local src = source
    if Speakers[id] and Speakers[id].isMoving and Speakers[id].playerMoving == src then
        Speakers[id].coords = coords
        -- replica coords para todos os clientes durante o movimento
        TriggerClientEvent('mri_Qboombox:client:syncLastCoordsSync', -1, id, coords)
    end
end)
