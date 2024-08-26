Config = Config or {}

Config.framework = 'qbcore' --(qbcore/esx/custom)
Config.useItem = false -- If disabled, you can use the command /createSpeaker
Config.fixSpeakersCommand = "fixSpeakers" --If speakers dont load use this command to reload all the speakers
Config.createSpeaker = "jbl" -- Your custom command to create speaker
Config.itemName = 'speaker' --You need to had this item created in your config or database
Config.timeZone = "America/Sao_Paulo" --IMPORTANT to set what time zone is your server in https://gist.github.com/mur4i/357734b2baebe353fe932302fb561650
Config.KeyAccessUi = 38
Config.KeyDeleteSpeaker = 194
Config.KeyToMove = 311
Config.KeyToPlaceSpeaker = 191
Config.KeyToChangeAnim = 311
Config.RadioProp = 'gordela_boombox3' -- Defina o prop do rádio (default = prop_boombox_01)


Config.Translations = {
    notEnoughDistance = 'Você deve manter um pouco mais de distância do outro alto-falante próximo.',
    helpNotify = 'Pressione ~INPUT_CONTEXT~ para acessar o alto-falante, ~INPUT_FRONTEND_RRIGHT~ para deletá-lo ou ~INPUT_REPLAY_SHOWHOTKEY~ para segurar o boombox',
    libraryLabel = 'Sua biblioteca',
    searchLabel = 'Procurar por Nome/URL',
    newPlaylistLabel = 'Criar nova Playlist',
    importPlaylistLabel = 'Importar uma Playlist existente',
    newPlaylist = 'Nova Playlist',
    playlistName = 'Nome da Playlist',
    addSong = 'Adicionar música',
    deletePlaylist = 'Deletar Playlist',
    unkown = 'Desconhecido',
    titleFirstMessage = "Ainda não tem uma playlist?",
    secondFirstMessage = "Crie uma Playlist",
    holdingBoombox = 'Pressione ~INPUT_FRONTEND_RDOWN~ para colocar o alto-falante ou ~INPUT_REPLAY_SHOWHOTKEY~ para mudar a animação'
}
