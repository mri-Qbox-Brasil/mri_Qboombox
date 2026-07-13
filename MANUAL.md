# MANUAL - mri_Qboombox

## O que o recurso faz (descrição funcional)
Player de música YouTube com objetos alto-falantes colocáveis no mundo e em veículos para servidores FiveM. Permite reprodução de músicas, gerenciamento de playlists com import/export via códigos e áudio 3D posicional.

## Funcionalidades principais
- **Integração YouTube**: Reprodução de URLs do YouTube, suporte a playlists.
- **Objetos alto-falantes**: Colocação no mundo ou em veículos, persistência após reinícios.
- **Controles de reprodução**: Play/pause, skip, loop, aleatório, volume ajustável, controle de distância.
- **Gerenciamento de playlists**: Criação, import/export via códigos, armazenamento persistente.
- **Áudio 3D**: Som posicional realista no mundo do GTA V.

## Como funciona (fluxo de trabalho)

### Colocação de alto-falante
1. Jogador usa comando `/createSpeaker` para criar objeto alto-falante.
2. Objeto é posicionado nas coordenadas do jogador, salvo no DB.

### Reprodução de música
1. Jogador interage com o alto-falante (via target ou comando `/som`/`/caixa`).
2. Abre menu de controle, insere URL do YouTube.
3. Música começa a tocar, áudio 3D com distância configurada.

### Gerenciamento de playlists
1. Jogador cria playlist, adiciona faixas.
2. Exporta playlist via código, compartilha com outros jogadores.
3. Outro jogador importa código, carrega playlist.

## Opções de configuração disponíveis
Configurações em `config/config.lua`:

| Opção | Padrão | Descrição |
|-------|--------|-----------|
| `Config.Framework` | `'qb'` | `'qb'`, `'esx'`, ou `'custom'`. |
| `Config.Speaker.model` | `'prop_speaker_06'` | Modelo do objeto alto-falante. |
| `Config.Speaker.maxDistance` | `50.0` | Distância máxima do áudio. |
| `Config.Speaker.defaultVolume` | `0.5` | Volume padrão (0.0-1.0). |
| `Config.Speaker.allowVehicle` | `true` | Permite alto-falantes em veículos. |
| `Config.Playlist.maxPlaylists` | `10` | Máximo de playlists por jogador. |
| `Config.Playlist.maxTracks` | `50` | Máximo de faixas por playlist. |
| `Config.Playlist.enableImportExport` | `true` | Habilita códigos de import/export. |
| `Config.YouTube.enabled` | `true` | Habilita integração YouTube. |

## Comandos disponíveis
| Comando | Permissão | Descrição |
|---------|------------|-------------|
| `/createSpeaker` | Todos | Cria novo objeto alto-falante. |
| `/fixSpeakers` | Admin | Corrige/reset todos os alto-falantes. |
| `/som` | Todos | Alterna menu de música (alias). |
| `/caixa` | Todos | Alterna menu de música (alias). |

## Eventos que dispara/ouve

### Cliente → Servidor
| Evento | Parâmetros | Descrição |
|--------|------------|-----------|
| `mri_Qboombox:client:openMenu` | `speakerId` | Abre menu de controle do alto-falante. |
| `mri_Qboombox:client:playMusic` | `url, volume, distance` | Toca música no alto-falante. |
| `mri_Qboombox:client:stopMusic` | `speakerId` | Para música no alto-falante. |
| `mri_Qboombox:client:createSpeaker` | `coords, heading` | Cria objeto alto-falante. |
| `mri_Qboombox:client:deleteSpeaker` | `speakerId` | Deleta objeto alto-falante. |

### Servidor → Cliente
| Evento | Parâmetros | Descrição |
|--------|------------|-----------|
| `mri_Qboombox:server:saveSpeaker` | `speakerData` | Salva alto-falante no DB. |
| `mri_Qboombox:server:deleteSpeaker` | `speakerId` | Deleta alto-falante do DB. |
| `mri_Qboombox:server:savePlaylist` | `playlistData` | Salva playlist no DB. |
| `mri_Qboombox:server:loadPlaylist` | `playlistId` | Carrega playlist do DB. |
| `mri_Qboombox:server:importPlaylist` | `code` | Importa playlist via código. |
| `mri_Qboombox:server:exportPlaylist` | `playlistId` | Exporta playlist como código. |

## Exports que fornece/consome

### Exports do cliente
| Export | Parâmetros | Descrição |
|--------|------------|-----------|
| `createSpeaker` | `coords, heading` | Cria alto-falante. |
| `playMusic` | `speakerId, youtubeUrl, volume, distance` | Toca música. |
| `stopMusic` | `speakerId` | Para música. |
| `getSpeakers` | Nenhum | Obtém todos os alto-falantes. |
| `deleteSpeaker` | `speakerId` | Deleta alto-falante. |

### Exports do servidor
| Export | Parâmetros | Descrição |
|--------|------------|-----------|
| `saveSpeaker` | `source, speakerData` | Salva no DB. |
| `getAllSpeakers` | Nenhum | Obtém todos os alto-falantes. |
| `savePlaylist` | `source, playlistData` | Salva playlist no DB. |
| `importPlaylist` | `code` | Importa playlist. |
| `exportPlaylist` | `playlistId` | Exporta playlist. |

### Exports consumidos
Nenhum export externo consumido diretamente, usa oxmysql para persistência.

## Integração com outros recursos MRI Qbox
- **oxmysql**: Persistência de alto-falantes e playlists.
- **ox_lib**: Componentes UI e notificações.
- **Frameworks (QBCore/ESX/Custom)**: Verificação de identidade do jogador para dono de alto-falantes.

## Casos de uso / exemplos práticos
1. **Festa em casa**: Jogador cria alto-falante na sala, toca playlist do YouTube, convida amigos.
2. **Som no carro**: Jogador monta alto-falante no veículo, toca música durante passeio.
3. **Compartilhamento de playlist**: Jogador exporta playlist de lo-fi, envia código a amigo que importa e ouve a mesma playlist.
4. **Evento de rua**: Admin cria multiple alto-falantes em bloco de festa, todos tocam a mesma música.

## Dicas de solução de problemas
- **Música não toca**: Verifique se a URL do YouTube é válida e o backend de áudio está configurado.
- **Alto-falante não aparece**: Confirme que o modelo `prop_speaker_06` está disponível ou altere para outro modelo.
- **Áudio não é 3D**: Verifique a distância configurada e se o jogador está dentro do raio.
- **Erros de banco de dados**: Importe `database/database.sql` e verifique oxmysql.
- **Comandos não funcionam**: Confira permissões de comando no server.cfg.
