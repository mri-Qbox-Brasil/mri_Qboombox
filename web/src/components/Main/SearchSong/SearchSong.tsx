import { PlayerPlay, Plus, Search } from "tabler-icons-react";
import { ActionIcon } from "@mantine/core";
import { useCallback, useEffect, useRef, useState } from "react";
import { fetchNui } from "../../../utils/fetchNui";
import "../../../App.css";
import { waveform } from "ldrs";

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



  const fetchSearchResults = async (query: string) => {
    setLoading(true);
  
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
  
    try {
      const results = await fetchNui("getSearchFromApitube", { query });
  
      if (results.length > 0) {
        setSearchResults(results);
      } else {
        console.warn("No results found, setting mock data");
        setSearchResults(mockData); // Usa mock se nenhum resultado for encontrado
      }
    } catch (error) {
      console.error("Error fetching search results, setting mock data:", error);
      setSearchResults(mockData); // Usa mock data em caso de erro
    } finally {
      setLoading(false);
    }
  };
  
  const debounce = useCallback(
    (func: (...args: any[]) => void, delay: number) => {
      let timeout: number;
      return (...args: any[]) => {
        clearTimeout(timeout);
        timeout = setTimeout(() => {
          func(...args);
        }, delay);
      };
    },
    []
  );

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setInputValue(e.target.value);
  };


  const truncateString = (str: string, maxLength: number): string => {
    if (str.length > maxLength) {
      return str.slice(0, maxLength) + '...';
    }
    return str;
  };

  // const removeFocus = () => {
  //   return () => {
  //     if (inputRef.current) {
  //       inputRef.current.blur();
  //     }
  //   };
  // }

  waveform.register();

  //EFFECTS

useEffect(() => {
  setLoading(true);
  if (inputValue.length >= 3) {
    const debouncedFetch = debounce(() => {
      fetchSearchResults(inputValue);
    }, 500);

    debouncedFetch();
   
  } else {
    setSearchResults([]);
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
        {loading && (<div className="loading">
          <l-waveform
            size="35"
            stroke="3.5"
            speed="1"
            color="white"
          ></l-waveform>
        </div>
          
        )}

        {!loading &&
          searchResults.map((result, index) => (
            <div className="searchResultItem" key={index}>
              <img className="thumbnail" src={result.thumbnail} alt={result.title} />
              <h3>{truncateString(result.title, 22)}</h3>
              <p>{truncateString(result.description, 60)}</p>
              <a href={result.url} target="_blank" rel="noopener noreferrer">
                {/* TODO MUSIC REPRO INTEGRATION*/}
                {/* <ActionIcon onClick={()=>{fetchNui("Playsong", result.url)}} color="green" style={{borderRadius: '20px'}} variant="filled">                            
                <PlayerPlay color="black" strokeWidth={1}/>
                </ActionIcon> */}

                
                <div className="fixedIcons">
                <ActionIcon  onClick={()=>{console.log(result.url)}} color="green" style={{borderRadius: '20px'}} variant="filled">                            
                <PlayerPlay color="black" strokeWidth={1}/>
                </ActionIcon>

                <ActionIcon  onClick={()=>{console.log(result.url)}} color="green" style={{borderRadius: '20px'}} variant="filled">                            
                <Plus color="black" strokeWidth={1}/>
                </ActionIcon>
                </div>
                
              </a>
            </div>
          ))}
      </div>
    </div>
  );
}
