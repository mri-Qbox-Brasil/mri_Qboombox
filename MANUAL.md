# mri_Qboombox — Manual

Caixa de som portátil com player de YouTube: o jogador coloca o prop no mundo (ou usa o som do próprio veículo), toca playlists e o áudio é espacializado por distância para todos por perto.

---

## Sumário

1. [Dependências](#dependências)
2. [Instalação](#instalação)
3. [Configuração](#configuração)
4. [Comandos](#comandos)
5. [Controles](#controles)
6. [Uso da caixa de som](#uso-da-caixa-de-som)
7. [Som no veículo](#som-no-veículo)
8. [Playlists](#playlists)
9. [Banco de dados](#banco-de-dados)
10. [Integrações](#integrações)
11. [Limitações conhecidas](#limitações-conhecidas)
12. [Entrypoints para outros recursos](#entrypoints-para-outros-recursos)
13. [Estrutura de arquivos](#estrutura-de-arquivos)

---

## Dependências

| Recurso | Obrigatório | Observação |
|---|---|---|
| `oxmysql` | Sim | Declarado em `dependencies`. Guarda playlists e músicas |
| `qb-core` | Sim (`framework = 'qbcore'`) | Usado para `GetPlayer`, `AddItem`/`RemoveItem` e `CreateUseableItem` |
| `es_extended` | Sim (`framework = 'esx'`) | Requer descomentar `shared_script '@es_extended/imports.lua'` no `fxmanifest.lua`, senão as funções de item falham |
| `ox_target` | Não | Adiciona as opções "Carregar boombox" e "Guardar boombox" no prop |
| `qb-target` | Não | Alternativa ao `ox_target`, com as mesmas duas opções |

Se `Config.framework = 'custom'`, as funções `AddItem`, `DeleteItem` e o registro de item usável ficam vazias — é preciso preenchê-las em `server/server_edit.lua`.

---

## Instalação

1. Copie a pasta `mri_Qboombox` para `resources/`.
2. Adicione ao `server.cfg`, depois do `oxmysql` e do framework:
   ```
   ensure mri_Qboombox
   ```
3. As tabelas MySQL são criadas automaticamente no start do recurso (`server/db.lua` lê o `database.sql` e executa cada statement). Importar o `database.sql` na mão é opcional.
4. Se `Config.useItem = true` (padrão), cadastre o item `speaker` no seu inventário. Sem o item, não há como criar a caixa de som — o comando `/createSpeaker` só existe quando `useItem = false`.
5. Ajuste `Config.timeZone` para o fuso do **servidor**. A sincronia entre a música tocando e o tempo dos ouvintes depende disso.
6. **Conflito** — o recurso registra um evento de rede com o nome genérico `TriggerCallback` (sistema de callback próprio, em `client/Modules/Functions.lua` e `server/Modules/Functions.lua`). Outro recurso que use o mesmo nome de evento vai colidir.

O prop `gordela_boombox3` já vem em `stream/` e é registrado via `data_file 'DLC_ITYP_REQUEST'` — nada a instalar à parte.

---

## Configuração

Arquivo: `Config.lua` (carregado no client e no server).

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `Config.framework` | string | Sim | `qbcore`, `esx` ou `custom`. Define de onde vêm as funções de item |
| `Config.useItem` | bool | Sim | `true`: a caixa é criada ao usar o item `Config.itemName`. `false`: a caixa é criada pelo comando `/createSpeaker` e nenhum item é consumido |
| `Config.itemName` | string | Sim | Nome do item de caixa de som no inventário. Padrão: `speaker`. Consumido ao colocar, devolvido ao guardar |
| `Config.fixSpeakersCommand` | string | Sim | Nome do comando de cliente que recarrega a lista de caixas de som. Padrão: `fixSpeakers` |
| `Config.timeZone` | string | Sim | Fuso horário do servidor no formato IANA (ex.: `America/Sao_Paulo`). Usado pela UI para calcular em que ponto da música entrar |
| `Config.RadioProp` | string | Sim | Modelo do prop da caixa de som. Padrão: `gordela_boombox3` (vem em `stream/`) |
| `Config.KeyAccessUi` | number | Sim | Control ID para abrir a UI da caixa próxima **e** para alternar a animação de carregar. Padrão: `38` (E) |
| `Config.KeyToPlaceSpeaker` | number | Sim | Control ID para largar a caixa no chão enquanto carrega. Padrão: `191` (Enter) |
| `Config.KeyToChangeAnim` | number | Sim | Control ID para alternar entre carregar no ombro e carregar na mão. Padrão: `38` (E) |
| `Config.Translations` | tabela | Sim | Textos exibidos no jogo e na UI — ver abaixo |

### `Config.Translations`

| Chave | Onde aparece |
|---|---|
| `notEnoughDistance` | Notificação ao tentar colocar uma caixa a menos de 2 metros de outra |
| `helpNotify` | Help text ao chegar perto de uma caixa |
| `holdingBoombox` | Help text enquanto carrega a caixa |
| `libraryLabel` | Título da biblioteca na UI |
| `newPlaylistLabel`, `newPlaylist`, `playlistName` | Textos do fluxo de criar playlist |
| `importPlaylistLabel` | Texto do fluxo de importar playlist |
| `addSong`, `deletePlaylist` | Ações do menu de playlist |
| `unkown` | Fallback para música sem autor/nome |
| `titleFirstMessage`, `secondFirstMessage` | Estado vazio da biblioteca (nenhuma playlist) |

---

## Comandos

Nenhum comando tem verificação de permissão — todos estão disponíveis para qualquer jogador.

| Comando | Permissão | Descrição |
|---|---|---|
| `/som` | Nenhuma | Estando dentro de um veículo, transforma o veículo em caixa de som e abre a UI. Fora do veículo, apenas notifica |
| `/caixa` | Nenhuma | Abre a UI da caixa de som que estiver a menos de 1,5 m — mesmo efeito de pressionar a tecla de acesso |
| `/createSpeaker` | Nenhuma | Cria uma caixa de som na sua posição. **Só existe quando `Config.useItem = false`** |
| `/fixSpeakers` | Nenhuma | Comando de cliente: recarrega do servidor a lista de caixas de som. Use quando uma caixa não estiver aparecendo/tocando. O nome vem de `Config.fixSpeakersCommand` |

---

## Controles

| Tecla (padrão) | Contexto | Ação |
|---|---|---|
| `E` (`Config.KeyAccessUi`) | A menos de 1,5 m de uma caixa, a pé | Abre a UI do player |
| `E` (`Config.KeyToChangeAnim`) | Carregando a caixa | Alterna entre carregar no ombro e carregar na mão |
| `Enter` (`Config.KeyToPlaceSpeaker`) | Carregando a caixa | Larga a caixa no chão, na posição atual |

Dentro do veículo a tecla de acesso é ignorada — use `/som`.

---

## Uso da caixa de som

1. **Colocar** — usar o item `speaker` (ou `/createSpeaker` se `useItem = false`). O item é consumido, o personagem faz a animação de abaixar e o prop é criado no chão. Não é possível colocar a menos de 2 metros de outra caixa ativa.
2. **Tocar** — chegue perto e pressione `E` (ou `/caixa`). A UI abre com a sua biblioteca; escolher uma música toca em todas as caixas para todos os jogadores no raio.
3. **Volume e distância** — ajustáveis na UI. A distância é limitada pelo servidor entre **2 e 50 metros** (valores fora disso são clampados). O volume ouvido cai proporcionalmente à distância até a caixa.
4. **Carregar/mover** — com `ox_target` ou `qb-target`, escolha "Carregar boombox". A caixa passa a acompanhar o personagem e a posição é sincronizada com os demais jogadores a cada 250 ms. `Enter` larga no lugar.
5. **Guardar** — pelo target, "Guardar boombox". A caixa é desativada, o prop é removido e o item `speaker` volta para o inventário (quando `useItem = true`).

Enquanto uma música toca, o servidor avança sozinho para a próxima faixa da playlist ao fim da duração da atual, voltando à primeira quando a lista acaba.

---

## Som no veículo

`/som` dentro de um veículo cria uma "caixa" virtual atrelada ao `netId` do veículo, sem prop e sem consumir item. A posição do som acompanha o veículo em tempo real.

O servidor faz uma varredura a cada 5 segundos e remove automaticamente as caixas de veículo cujo veículo não existe mais. As mesmas regras de distância mínima (2 m de outra caixa) valem aqui.

---

## Playlists

Playlists e músicas são por **license** do jogador e ficam no MySQL.

- **Criar** — a UI cria a playlist e vincula ao seu license.
- **Adicionar música** — a URL do YouTube é resolvida na UI (nome, autor, duração) e gravada em `mri_qsongs`. Se a URL já existe na tabela, a música é reaproveitada em vez de duplicada.
- **Importar** — o "código" de importação é o **ID numérico da playlist**. Importar apenas vincula o seu license à playlist existente; ela continua pertencendo ao dono original.
- **Remover música** — só o dono da playlist (`owner` = license) pode remover músicas dela.
- **Apagar playlist** — remove apenas o **seu** vínculo (`mri_qplaylists_users`). A playlist em si só some para você.

---

## Banco de dados

Quatro tabelas, criadas automaticamente no start:

| Tabela | Conteúdo |
|---|---|
| `mri_qplaylists` | Playlists: `id`, `name`, `owner` (license do criador) |
| `mri_qsongs` | Músicas: `id`, `url` (único), `name`, `author`, `maxDuration` em segundos |
| `mri_qplaylist_songs` | Ligação playlist ↔ música (cascade em delete) |
| `mri_qplaylists_users` | Ligação license ↔ playlist. É o que define quais playlists cada jogador vê |

As caixas de som **não** são persistidas — ver [Limitações conhecidas](#limitações-conhecidas).

---

## Integrações

### ox_target

Se o `ox_target` estiver iniciado, o recurso registra duas opções no modelo `Config.RadioProp` via `exports.ox_target:addModel`:

- **Carregar boombox** — pega a caixa para movê-la.
- **Guardar boombox** — desativa a caixa e devolve o item.

### qb-target

Mesmo comportamento, registrado com `exports['qb-target']:AddTargetModel` e distância de 2.0. Os dois blocos são independentes: se ambos os recursos estiverem iniciados, as opções são registradas nos dois.

Sem nenhum dos dois targets, **não há como pegar nem guardar a caixa** — só usar o player.

---

## Limitações conhecidas

- **Caixas não persistem entre restarts.** A tabela `Speakers` vive em memória no servidor. Reiniciar o recurso ou o servidor apaga todas as caixas colocadas (e os itens consumidos não voltam). Só playlists e músicas ficam no banco.
- **Caixas apagadas não são removidas da lista.** Guardar uma caixa marca `permaDisabled = true`, mas a entrada continua no array e nos índices — a lista cresce até o restart.
- **Eventos de servidor sem validação de dono.** `Playsong`, `SyncNewVolume`, `SyncNewDist`, `nextSong`, `prevSong` e `pauseSong` aceitam qualquer índice de caixa vindo do cliente, sem checar distância nem permissão.
- **`/fixSpeakers` é comando de cliente sem permissão** — qualquer jogador pode executar. Ele só recarrega a lista local, não altera nada no servidor.

---

## Entrypoints para outros recursos

O recurso **não expõe exports**. A superfície é composta por eventos de rede e pela função global de servidor `CreateSpeaker`.

### Função de servidor `CreateSpeaker(src)`

Global do servidor (não é export). Cria uma caixa na posição do jogador, respeitando a distância mínima de 2 m, consumindo o item se `Config.useItem = true`. É o que o item usável e o `/createSpeaker` chamam.

```lua
-- dentro do próprio recurso
CreateSpeaker(source)
```

### `mri_Qboombox:server:createVehicleSpeaker`

Cria uma caixa atrelada a um veículo. É o evento por trás do `/som`.

```lua
TriggerServerEvent('mri_Qboombox:server:createVehicleSpeaker', {
    volume = 50, url = '', coords = vehicleCoords, playlistPLaying = {},
    time = 0, maxDistance = 15, isPlaying = false, maxDuration = 5000000,
    songId = -2, permaDisabled = false, paused = false, pausedTime = 0,
    isMoving = false, playerMoving = -2,
    isVehicleSpeaker = true,
    vehicle = NetworkGetNetworkIdFromEntity(vehicle),
})
```

### `mri_Qboombox:server:deleteBoombox`

Desativa uma caixa e devolve o item ao jogador. Exige o índice da caixa e o `x` das coordenadas dela como conferência.

```lua
TriggerServerEvent('mri_Qboombox:server:deleteBoombox', speakerIndex, speakerCoords.x)
```

### Eventos server → client

| Evento | Payload | Descrição |
|---|---|---|
| `mri_Qboombox:client:insertSpeaker` | `(data)` | Uma caixa nova foi criada |
| `mri_Qboombox:client:updateBoombox` | `(id, data)` | Estado completo da caixa mudou (música, pausa, tempo) |
| `mri_Qboombox:client:updateVolume` | `(id, volume)` | Volume alterado |
| `mri_Qboombox:client:updateDist` | `(id, dist)` | Distância máxima alterada |
| `mri_Qboombox:client:deleteBoombox` | `(id)` | Caixa desativada |
| `mri_Qboombox:client:syncLastCoords` | `(id, coords)` | Caixa foi largada em uma posição final |
| `mri_Qboombox:client:notify` | `(msg)` | Notificação simples na tela |

---

## Estrutura de arquivos

```
mri_Qboombox/
├── Config.lua                    — framework, item, teclas, prop, fuso horário e textos
├── client/
│   ├── client.lua                — loop de distância/volume, UI, carregar e largar a caixa, targets, /som e /caixa
│   ├── client_edit.lua           — helpers de notificação (help text e notification)
│   └── Modules/
│       └── Functions.lua         — lado cliente do sistema de callback próprio (TriggerCallback)
├── server/
│   ├── server.lua                — estado das caixas, sincronização, troca de faixa, CRUD de playlists
│   ├── server_edit.lua           — bridge de framework: AddItem/DeleteItem e item usável ou /createSpeaker
│   ├── db.lua                    — cria as tabelas lendo o database.sql no start
│   └── Modules/
│       └── Functions.lua         — lado servidor do sistema de callback próprio
├── database.sql                  — mri_qplaylists, mri_qsongs, mri_qplaylist_songs, mri_qplaylists_users
├── stream/                       — prop gordela_boombox3 (ydr, ymap, ymf, ytyp)
├── web/
│   ├── build/                    — UI compilada (ui_page): player de YouTube, biblioteca e playlists
│   └── src/                      — fonte React da UI
└── fxmanifest.lua
```
