import { PlayerPlay, Plus, Search } from "tabler-icons-react";
import { ActionIcon } from "@mantine/core";
import { useCallback, useEffect, useRef, useState } from "react";
import { fetchNui } from "../../../utils/fetchNui";
import "../../../App.css";
import { waveform } from "ldrs";
import { Loader } from "../Loader/Loader";
import { debounce } from "../../../utils/debounce";

interface SearchResult {
  title: string;
  description: string;
  thumbnail: string;
  videoId: string;
  url: string;
}

export interface Song {
  id: number;
  name: string;
  author: string;
  maxDuration: number;
  url: string;
}

export interface Playlist {
  id: number;
  name: string;
  songs: Song[];
}

interface Props {
  playSong: (songUrl: string, playlist: Playlist, index: number) => void;
  Playlists: Playlist[];
  setPlaylistActive: (i: number) => void;
  playlistActive: number;
  setOpenedPlaylist: (val: boolean) => void;
}

export default function SearchSong({
  playSong,
  Playlists,
  playlistActive,
  setOpenedPlaylist,
}: Props) {
  const [searchLabel, setSearchLabel] = useState("Search song by name or URL");
  const [inputValue, setInputValue] = useState("");
  const [searchResults, setSearchResults] = useState<SearchResult[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const inputRef = useRef<HTMLInputElement>(null);

  const getSearchLabel = async () => {
    try {
      const res = await fetchNui<string>("getSearchLabel");
      if (res) {
        setSearchLabel(res);
      }
    } catch (e) {
      console.error(e);
    }
  };

  const mockData = [
    {
      title: "FINGI SER LEIGO E TENTEI COMPRAR UM PC GAMER NA SANTA IFIGÊNIA",
      description: "https://www.youtube.com/watch?v=M_Khlu_N4-g",
      thumbnail: "https://picsum.photos/200/300",
      videoId: "1",
      url: "https://youtube.com",
    },
    {
      title: "Música Teste 2",
      description: "Nome do Canal",
      thumbnail: "https://picsum.photos/200/300",
      videoId: "2",
      url: "https://youtube.com",
    },
    {
      title: "Slipknot - Surfacing (Official Music Video) [HD]",
      description: "Slipknot",
      thumbnail: "https://picsum.photos/200/300",
      videoId: "3",
      url: "https://youtube.com",
    },
    {
      title: "Música Teste 4",
      description: "Nome do Canal",
      thumbnail: "https://picsum.photos/200/300",
      videoId: "4",
      url: "https://youtube.com",
    },
    {
      title: "Música Teste 5",
      description: "Nome do Canal",
      thumbnail: "https://picsum.photos/200/300",
      videoId: "5",
      url: "https://youtube.com",
    },
    {
      title: "Música Teste 6",
      description: "Nome do Canal",
      thumbnail: "https://picsum.photos/200/300",
      videoId: "6",
      url: "https://youtube.com",
    },
  ];


  const debounceSearch = useCallback(
    debounce(async (query: string) => {
      if (query) {
        try {
          setLoading(true);
          const results = await fetchNui("getSearchFromApitube", { query });
          setSearchResults(results);
        } catch {
          setSearchResults(mockData);
          console.log("Erro: Definindo dados mockados para setSearchResults");
        } finally {
          setLoading(false);
        }
      }
    }, 1500),
    []
  );

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    setInputValue(value);
  };

  const truncateString = (str: string, maxLength: number): string => {
    if (str.length > maxLength) {
      return str.slice(0, maxLength) + "...";
    }
    return str;
  };

  waveform.register();

  //EFFECTS

  useEffect(() => {
    if (inputValue.length >= 3) {
      setLoading(true);
      debounceSearch(inputValue);
      setLoading(false);
    }
  }, [inputValue]);

  useEffect(() => {
    getSearchLabel();
  }, []);

  return (
    <div className="searchSongContainer">
      <div className="searchSongHeader">
        <Search strokeWidth={2} color={"white"} />
        <input
          className="searchInput"
          type="text"
          placeholder={searchLabel}
          value={inputValue}
          onChange={handleInputChange}
          ref={inputRef}
        />
      </div>
      <div className="searchResultContainer">
        {loading && <Loader show={loading} />}

        {!loading &&
          searchResults.map((result, index) => (
            <div className="searchResultItem" key={index}>
              <img
                className="thumbnail"
                src={result.thumbnail}
                alt={result.title}
              />
              <h3 className="resultTitle">
                {truncateString(result.title, 50)}
              </h3>
              <p className="resultAuthor">
                {truncateString(result.description, 60)}
              </p>
              <a href={result.url} target="_blank" rel="noopener noreferrer">
                {/* TODO MUSIC REPRO INTEGRATION*/}
                {/* <ActionIcon onClick={()=>{fetchNui("Playsong", result.url)}} color="green" style={{borderRadius: '20px'}} variant="filled">                            
                <PlayerPlay color="black" strokeWidth={1}/>
                </ActionIcon> */}
              </a>
              <div className="fixedIcons">
                <ActionIcon
                  onClick={() => {
                    console.log(result.url);
                  }}
                  color="green"
                  style={{ borderRadius: "20px" }}
                  variant="filled"
                >
                  <PlayerPlay color="black" strokeWidth={1} />
                </ActionIcon>

                <ActionIcon
                  onClick={() => {
                    console.log(result.url);
                  }}
                  color="green"
                  style={{ borderRadius: "20px" }}
                  variant="filled"
                >
                  <Plus color="black" strokeWidth={1} />
                </ActionIcon>
              </div>
            </div>
          ))}
      </div>
    </div>
  );
}
