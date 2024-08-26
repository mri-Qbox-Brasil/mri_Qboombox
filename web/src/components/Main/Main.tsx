import { useState } from "react";
import Library from "./Library/Library";
import DisplayPlaylist from "./DisplayPlaylist/DisplayPlaylist";
import { Playlist } from "./Library/Library";
import { fetchNui } from "../../utils/fetchNui";
import { useNuiEvent } from "../../hooks/useNuiEvent";
import ModalAddPlaylist from "./Library/LibraryMenu/ModalAddPlaylist/ModalAddPlaylist";
import SearchSong from "./SearchSong/SearchSong";
import { Tabs } from "@mantine/core";
import "./../../App.css";
import { Heart, Search } from "tabler-icons-react";

interface Props {
  playSong: (songUrl: string, playlist: Playlist, index: number) => void;
}

export default function Main({ playSong }: Props) {
  const [Playlists, setPlaylists] = useState<Playlist[]>([]);
  const [openedCreatePlaylist, setOpenedCreatePlaylist] = useState(false);
  const [playlistActive, setPlaylistActive] = useState(0);
  const newPlaylist = async (name: string) => {
    try {
      const res = await fetchNui<number>("getNewPlaylist", name);
      if (res) {
        if (Playlists.length === 0) {
          setPlaylists([{ id: res, name: name, songs: [] }]);
        } else {
          const newPlaylist: Playlist = {
            id: res,
            name: name,
            songs: [],
          };

          setPlaylists((prevPlaylists) => [...prevPlaylists, newPlaylist]);
        }
      }
    } catch (e) {
      console.error(e);
    }
  };
  const getPlaylists = async () => {
    try {
      const res = await fetchNui<Playlist[]>("getPlaylists");
      setPlaylists(res);
    } catch (e) {
      console.error(e);
    }
  };

  const deletePlaylist = async () => {
    setPlaylistActive(!playlistActive ? 0 : playlistActive - 1);
    fetchNui("deletePlayList", Playlists[playlistActive].id);
  };

  useNuiEvent("getPlaylists", getPlaylists);

  const [activeTab, setActiveTab] = useState<string | null>("searchSong");

  return (
    <div className="main">
      <Tabs
        className="tabsContainer"
        radius="sm"
        variant="pills"
        color="green"
        orientation="vertical"
        defaultValue="searchSong"
        value={activeTab}
        onChange={() => setActiveTab}
      >
        <Tabs.List>
          <Tabs.Tab
            value="searchSong"
            onClick={() => setActiveTab("searchSong")}
          >
            <Search strokeWidth={1.5} color={"white"} />
          </Tabs.Tab>
          <Tabs.Tab
            value="myPlaylists"
            onClick={() => setActiveTab("myPlaylists")}
          >
            <Heart strokeWidth={1.1} color={"white"} />
          </Tabs.Tab>
        </Tabs.List>

        <Tabs.Panel value="searchSong">
          <SearchSong
            Playlists={Playlists}
            setPlaylistActive={setPlaylistActive}
            playSong={playSong}
            playlistActive={playlistActive}
            setOpenedPlaylist={setOpenedCreatePlaylist}
          />
        </Tabs.Panel>
        <Tabs.Panel value="myPlaylists">
          <Library
            Playlists={Playlists}
            setPlaylistActive={setPlaylistActive}
            playlistActive={playlistActive}
            setOpenedPlaylist={setOpenedCreatePlaylist}
          />

          <ModalAddPlaylist
            opened={openedCreatePlaylist}
            close={() => {
              setOpenedCreatePlaylist(false);
            }}
            newPlaylist={newPlaylist}
          />
        </Tabs.Panel>

        <Tabs.Panel value="myPlaylists">
          <DisplayPlaylist
            Playlists={Playlists}
            playlistActive={playlistActive}
            playSong={playSong}
            exitPlaylist={() => {
              deletePlaylist();
            }}
            setOpenedPlaylist={setOpenedCreatePlaylist}
          />
        </Tabs.Panel>
      </Tabs>
    </div>
  );
}
