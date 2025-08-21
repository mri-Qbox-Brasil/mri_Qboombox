local speakers = {}
local isInUI = false
local playlistsLoaded = false
local reproInUi = -1
local movingASpeaker = false
local movingObject = 0
local movingSpeakerId = -1
local gangAnim = true
--edt 245
local lastSync = 0


function SendReactMessage(action, data)
    SendNUIMessage({
        action = action,
        data = data
    })
end

local function toggleNuiFrame(shouldShow)
    SetNuiFocus(shouldShow, shouldShow)
    isInUI = shouldShow
    SendReactMessage('setVisible', shouldShow)
    if shouldShow == false then
        reproInUi = -1
    end
end

RegisterNUICallback('hideFrame', function(_, cb)
    toggleNuiFrame(false)
    cb({})
end)

function LoadSpeakers()
    TriggerCallback('mri_Qboombox:callback:getBoomboxs', function(result)
        print('Try to load Speakers in nui')
        SendReactMessage('createReproGlobal', result)
        Wait(200)
        speakers = result
    end)
end

RegisterNUICallback('webLoaded', function()
    print('Loading speakers')
    Wait(100)
    LoadSpeakers()
end)

RegisterNUICallback('playSong', function(data)
    TriggerServerEvent('mri_Qboombox:server:Playsong', data)
end)

RegisterNUICallback('getNewPlaylist', function(data, cb)
    TriggerCallback('mri_Qboombox:callback:getNewPlaylist', function(result)
        cb(result)
    end, data)
end)

RegisterNetEvent('mri_Qboombox:client:notify', function(msg)
    ShowNotification(msg)
end)

RegisterNUICallback('tempChangeVolume', function (data)
    speakers[data.repro + 1].volume = data.volume
end)

RegisterNUICallback('changeDist', function(data)
    TriggerServerEvent('mri_Qboombox:server:SyncNewDist', data)
end)

RegisterNUICallback('syncVolume', function(data)
    TriggerServerEvent('mri_Qboombox:server:SyncNewVolume', data)
end)

RegisterNUICallback('deletePlayList', function(data)
    TriggerServerEvent('mri_Qboombox:server:deletePlayList', data)
end)

RegisterNUICallback('importNewPlaylist', function(data)
    TriggerServerEvent('mri_Qboombox:server:importNewPlaylist', data)
end)

RegisterNetEvent('mri_Qboombox:client:updateBoombox', function(id, data)
    speakers[id] = data
    if (id - 1) == reproInUi then
        SendReactMessage('sendSongInfo', {author= speakers[id].playlistPLaying.songs[speakers[id].songId].author, name = speakers[id].playlistPLaying.songs[speakers[id].songId].name, url = speakers[id].url, volume = speakers[id].volume, dist = speakers[id].maxDistance, maxDuration = speakers[id].maxDuration, paused = speakers[id].paused, pausedTime = speakers[id].pausedTime})
    end
end)

RegisterNetEvent('mri_Qboombox:client:updateVolume', function(id, vol)
    speakers[id].volume = vol
end)

RegisterNetEvent('mri_Qboombox:client:updateDist', function(id, dist)
    speakers[id].maxDistance = dist
end)

RegisterNetEvent('mri_Qboombox:client:doAnim', function()
    if not HasAnimDictLoaded('anim@heists@money_grab@briefcase') then
        RequestAnimDict('anim@heists@money_grab@briefcase')

        while not HasAnimDictLoaded('anim@heists@money_grab@briefcase') do
            Citizen.Wait(1)
        end
    end
    TaskPlayAnim(PlayerPedId(), 'anim@heists@money_grab@briefcase', 'put_down_case', 8.0, -8.0, -1, 1, 0, false, false, false)
    Citizen.Wait(1000)
    ClearPedTasks(PlayerPedId())
end)

RegisterNetEvent('mri_Qboombox:client:insertSpeaker', function(data)
    table.insert(speakers, data)
    SendReactMessage('createRepro', data.url)
end)

RegisterNetEvent('mri_Qboombox:client:deleteBoombox', function(id)
    speakers[id].permaDisabled = true
end)

RegisterNUICallback('prevSong', function(data)
    if data.repro == reproInUi then
        TriggerServerEvent('mri_Qboombox:server:prevSong', data)
    end
end)

RegisterNUICallback('nextSong', function(data)
    if data.repro == reproInUi then
        TriggerServerEvent('mri_Qboombox:server:nextSong', data)
    end
end)

RegisterNUICallback('pauseSong', function(data)
    if data.repro == reproInUi then
        TriggerServerEvent('mri_Qboombox:server:pauseSong', data)
    end
end)

RegisterNUICallback('syncNewTime', function(data)
    if data.repro == reproInUi then
        TriggerServerEvent('mri_Qboombox:server:syncNewTime', data)
    end
end)

function LoadAnima()
    if not HasAnimDictLoaded('missfinale_c2mcs_1') then
        RequestAnimDict('missfinale_c2mcs_1')

        while not HasAnimDictLoaded('missfinale_c2mcs_1') do
            Citizen.Wait(1)
        end
    end
end

TARGET_PICK_UP = false
TARGET_DELETE = false
------ CLIENT.LUA -> THREAD ------ 
Citizen.CreateThread(function()
    while true do
        local sleep = 500
        local player = PlayerPedId()
        local playerCoords = GetEntityCoords(player)
        local isInVehicle = IsPedInAnyVehicle(player, false) -- Verifica se o jogador está em um veículo

        for k, v in pairs(speakers) do
            -- Verifica se o alto-falante está vinculado a um veículo
            if v.isVehicleSpeaker and v.vehicle then
                local vehicle = NetworkGetEntityFromNetworkId(v.vehicle)
                if DoesEntityExist(vehicle) then
                    -- Atualiza as coordenadas do alto-falante para as coordenadas do veículo
                    v.coords = GetEntityCoords(vehicle)
                else
                    -- Se o veículo não existir mais, remove o alto-falante
                    speakers[k] = nil
                    SendReactMessage('stopSong', tonumber(k - 1))
                end
            end

            local distance = #(v.coords - playerCoords)
            if distance < v.maxDistance + 10 and sleep >= 100 then
                sleep = 100
            end
            if distance < v.maxDistance and not v.permaDisabled then
                sleep = 5
                if not v.isPlaying and v.url ~= '' and not v.paused then
                    SendReactMessage('playSong', {repro = tonumber(k - 1), url = v.url, volume = v.volume, time = v.time})
                    v.isPlaying = true
                end
                if not v.paused then
                    SendReactMessage('changeVolume', {repro = tonumber(k - 1), volume = tonumber(v.volume - (distance * v.volume / v.maxDistance))})
                else
                    SendReactMessage('changeVolume', {repro = tonumber(k - 1), volume = 0})
                end
                if distance < 1.5 and not v.isMoving then
                    if not movingASpeaker then
                        -- Verifica se o jogador NÃO está em um veículo antes de exibir a notificação
                        if not isInVehicle then
                            ShowHelpNotification(Config.Translations.helpNotify)
                        end
                    end
                    -- Verifica se o jogador NÃO está em um veículo antes de permitir o uso da tecla Config.KeyAccessUi
                    if IsControlJustPressed(1, Config.KeyAccessUi) and not movingASpeaker and not isInVehicle then
                        SendReactMessage('setRepro', tonumber(k - 1))
                        if not playlistsLoaded then
                            SendReactMessage('getPlaylists')
                        end
                        if v.playlistPLaying.songs and v.playlistPLaying.songs[v.songId] then
                            SendReactMessage('sendSongInfo', {author = v.playlistPLaying.songs[v.songId].author, name = v.playlistPLaying.songs[v.songId].name, url = v.url, volume = v.volume, dist = v.maxDistance, maxDuration = v.maxDuration, paused = v.paused, pausedTime = v.pausedTime})
                        end
                        toggleNuiFrame(true)
                        reproInUi = k - 1
                    end
                    if not isInUI and not movingASpeaker and TARGET_DELETE then
                        TARGET_DELETE = false
                        TriggerServerEvent('mri_Qboombox:server:deleteBoombox', k, v.coords.x)
                        Wait(200)
                    end
                    if not movingASpeaker and TARGET_PICK_UP then
                        TARGET_PICK_UP = false
                        TriggerCallback('mri_Qboombox:callback:canMove', function(canMove)
                            if canMove then
                                movingASpeaker = true
                                local ped = PlayerPedId()
                                local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(ped, 0.0, 3.0, 0.5))
                                local obj = CreateObjectNoOffset(Config.RadioProp, x, y, z, true, false)
                                SetModelAsNoLongerNeeded(Config.RadioProp)
                                movingObject = obj
                                movingSpeakerId = k
                                if gangAnim then
                                    LoadAnima()
                                    TaskPlayAnim(PlayerPedId(), 'missfinale_c2mcs_1', 'fin_c2_mcs_1_camman', 8.0, -8.0, -1, 51, 0, false, false, false)
                                    AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, 28422),0.0, 0.0, 0.1, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                                else
                                    AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, 57005), 0.32, 0, -0.05, 0.10, 270.0, 60.0, true, true, false, true, 1, true)
                                end
                            end
                        end, k)
                    end
                end
            else
                if v.isPlaying then
                    SendReactMessage('stopSong', tonumber(k - 1))
                    v.isPlaying = false
                end
            end
        end

        if movingASpeaker then
            sleep = 5
            -- Atualiza a posição local do speaker para acompanhar o objeto anexado
            local srcCoords
            if DoesEntityExist(movingObject) then
                -- pega a posição real da boombox (mais fiel que a do ped)
                srcCoords = GetEntityCoords(movingObject)
            else
                -- fallback: posição do jogador (se por algum motivo o objeto ainda não existir)
                srcCoords = GetEntityCoords(PlayerPedId())
            end

            if speakers[movingSpeakerId] then
                speakers[movingSpeakerId].coords = srcCoords
            end

            -- opcional: sincroniza com os demais (throttle a cada 250ms)
            local now = GetGameTimer()
            if (now - lastSync) > 250 then
                TriggerServerEvent('mri_Qboombox:server:syncMovingCoords', movingSpeakerId, srcCoords)
                lastSync = now
            end

            ShowHelpNotification(Config.Translations.holdingBoombox)

            if IsControlJustPressed(1, Config.KeyToPlaceSpeaker) then
                if not HasAnimDictLoaded('anim@heists@money_grab@briefcase') then
                    RequestAnimDict('anim@heists@money_grab@briefcase')
                    while not HasAnimDictLoaded('anim@heists@money_grab@briefcase') do
                        Citizen.Wait(1)
                    end
                end
                TaskPlayAnim(PlayerPedId(), 'anim@heists@money_grab@briefcase', 'put_down_case', 8.0, -8.0, -1, 1, 0, false, false, false)
                Citizen.Wait(1000)
                ClearPedTasks(PlayerPedId())
                DeleteEntity(movingObject)
                TriggerServerEvent('mri_Qboombox:server:updateObjectCoords', movingSpeakerId)
                movingSpeakerId = 0
                movingASpeaker = false
            end

            if IsControlJustPressed(1, Config.KeyToChangeAnim) then
                gangAnim = not gangAnim
                if gangAnim then
                    LoadAnima()
                    AttachEntityToEntity(
                        movingObject, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422),
                        0.0, 0.0, 0.1, 0.0, 0.0, 0.0, true, true, false, true, 1, true
                    )
                    TaskPlayAnim(PlayerPedId(), 'missfinale_c2mcs_1', 'fin_c2_mcs_1_camman', 8.0, -8.0, -1, 51, 0, false, false, false)
                else
                    ClearPedTasks(PlayerPedId())
                    AttachEntityToEntity(
                        movingObject, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005),
                        0.32, 0.0, -0.05, 0.10, 270.0, 60.0, true, true, false, true, 1, true
                    )
                end
            end
        end      
        Wait(sleep)
    end
end)

RegisterNetEvent('mri_Qboombox:client:updatePlayerMoving', function(id, src)
    speakers[id].isMoving = true
    speakers[id].playerMoving = src
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    DeleteEntity(movingObject)
end)

RegisterNUICallback('getPlaylists', function(_, cb)
    TriggerCallback('mri_Qboombox:callback:getPlaylists', function(result)
        cb(result)
    end)
end)

RegisterNetEvent('mri_Qboombox:client:syncLastCoords', function(id, coords)
    speakers[id].coords = coords
    speakers[id].isMoving = false
    speakers[id].playerMoving = -2
end)

RegisterNetEvent('mri_Qboombox:client:syncLastCoordsSync', function(id, coords)
    speakers[id].coords = coords
end)

RegisterNUICallback('addSong', function(data)
    TriggerServerEvent('mri_Qboombox:server:addSong', data)
end)

RegisterNUICallback('deleteSongPlaylist', function(data)
    TriggerServerEvent('mri_Qboombox:server:deleteSongPlaylist', data)
end)

RegisterNetEvent('mri_Qboombox:client:resyncPlaylists', function ()
    SendReactMessage('getPlaylists')
end)

RegisterNUICallback('getLibraryLabel', function(_, cb)
    cb(Config.Translations.libraryLabel)
end)

RegisterNUICallback('newPlaylistLabel', function(_, cb)
    cb(Config.Translations.newPlaylistLabel)
end)

RegisterNUICallback('playlistName', function(_, cb)
    cb(Config.Translations.playlistName)
end)

RegisterNUICallback('addSongLabel', function(_, cb)
    cb(Config.Translations.addSong)
end)

RegisterNUICallback('deletePlaylistLabel', function(_, cb)
    cb(Config.Translations.deletePlaylist)
end)

RegisterNUICallback('importPlaylistLabel', function(_, cb)
    cb(Config.Translations.importPlaylistLabel)
end)

RegisterNUICallback('Unkown', function(_, cb)
    cb(Config.Translations.unkown)
end)

RegisterNUICallback('titleFirstMessage', function(_, cb)
    cb(Config.Translations.titleFirstMessage)
end)

RegisterNUICallback('secondFirstMessage', function(_, cb)
    cb(Config.Translations.secondFirstMessage)
end)

RegisterNUICallback('timeZone', function(_, cb)
    cb(Config.timeZone)
end)

RegisterCommand(Config.fixSpeakersCommand, function ()
    LoadSpeakers()
end)


local propModel = Config.RadioProp or 'gordela_boombox3'

-- ox_target
if GetResourceState('ox_target') == 'started' then
    exports.ox_target:addModel(propModel, {
        {
            type = 'client',
            icon = 'fa-solid fa-hand',
            label = 'Carregar boombox',
            onSelect = function(data)
                local obj = data.entity
                if obj and DoesEntityExist(obj) then
                    TARGET_PICK_UP = true
                end
            end
        },
        {
            type = 'client',
            icon = 'fa-solid fa-arrow-up-from-bracket',
            label = 'Guardar boombox',
            onSelect = function(data)
                local obj = data.entity
                if obj and DoesEntityExist(obj) then
                    TARGET_DELETE = true
                end
            end
        }
    })
end

-- qb-target
if GetResourceState('qb-target') == 'started' then
    exports['qb-target']:AddTargetModel({ propModel }, {
        options = {
            {
                icon = 'fa-solid fa-hand',
                label = 'Carregar boombox',
                action = function(entity)
                    if entity and DoesEntityExist(entity) then
                        TARGET_PICK_UP = true
                    end
                end
            },
            {
                icon = 'fa-solid fa-arrow-up-from-bracket',
                label = 'Guardar boombox',
                action = function(entity)
                    if entity and DoesEntityExist(entity) then
                        TARGET_DELETE = true
                    end
                end
            }
        },
        distance = 2.0
    })
end



------ CLIENT.LUA -> Command ------ 
RegisterCommand('som', function()
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        -- Verifica se o jogador está dentro de um veículo
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local vehicleCoords = GetEntityCoords(vehicle)
        
        -- Define o veículo como o "alto-falante"
        local data = {
            volume = 50,
            url = '',
            coords = vehicleCoords,
            playlistPLaying = {},
            time = 0,
            maxDistance = 15,
            isPlaying = false,
            maxDuration = 5000000,
            songId = -2,
            permaDisabled = false,
            paused = false,
            pausedTime = 0,
            isMoving = false,
            playerMoving = -2,
            isVehicleSpeaker = true, -- Identifica que é um alto-falante de veículo
            vehicle = NetworkGetNetworkIdFromEntity(vehicle) -- Vincula o som ao veículo
        }
        
        -- Envia os dados para o servidor
        TriggerServerEvent('mri_Qboombox:server:createVehicleSpeaker', data)

        -- Aguarda um breve momento para garantir que o alto-falante seja criado
        Citizen.Wait(500)

        -- Simula o pressionamento da tecla E para abrir a interface do alto-falante
        local playerCoords = GetEntityCoords(playerPed)
        for k, v in pairs(speakers) do
            local distance = #(v.coords - playerCoords)
            
            if distance < 1.5 and not v.isMoving and not v.permaDisabled then
                -- Simula o pressionamento da tecla Config.KeyAccessUi
                SendReactMessage('setRepro', tonumber(k - 1))
                
                if not playlistsLoaded then
                    SendReactMessage('getPlaylists')
                end
                
                if v.playlistPLaying.songs and v.playlistPLaying.songs[v.songId] then
                    SendReactMessage('sendSongInfo', {
                        author = v.playlistPLaying.songs[v.songId].author,
                        name = v.playlistPLaying.songs[v.songId].name,
                        url = v.url,
                        volume = v.volume,
                        dist = v.maxDistance,
                        maxDuration = v.maxDuration,
                        paused = v.paused,
                        pausedTime = v.pausedTime
                    })
                end
                
                toggleNuiFrame(true)
                reproInUi = k - 1
                break
            end
        end
    else
        -- Se o jogador não estiver em um veículo, mostra uma notificação
        ShowNotification('Você precisa estar em um veículo para usar este comando.')
    end
end, false)


RegisterCommand('caixa', function()
    -- Verifica se o jogador está próximo de um speaker e simula o pressionamento da tecla
    local player = PlayerPedId()
    local playerCoords = GetEntityCoords(player)
    
    for k, v in pairs(speakers) do
        local distance = #(v.coords - playerCoords)
        
        if distance < 1.5 and not v.isMoving and not v.permaDisabled then
            -- Simula o pressionamento da tecla Config.KeyAccessUi
            SendReactMessage('setRepro', tonumber(k - 1))
            
            if not playlistsLoaded then
                SendReactMessage('getPlaylists')
            end
            
            if v.playlistPLaying.songs and v.playlistPLaying.songs[v.songId] then
                SendReactMessage('sendSongInfo', {
                    author = v.playlistPLaying.songs[v.songId].author,
                    name = v.playlistPLaying.songs[v.songId].name,
                    url = v.url,
                    volume = v.volume,
                    dist = v.maxDistance,
                    maxDuration = v.maxDuration,
                    paused = v.paused,
                    pausedTime = v.pausedTime
                })
            end
            
            toggleNuiFrame(true)
            reproInUi = k - 1
            break
        end
    end
end, false)

