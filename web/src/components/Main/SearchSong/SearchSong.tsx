import { Books, Heart, PlayerPlay, Search } from "tabler-icons-react";
import { Plus } from "tabler-icons-react";
import { ActionIcon } from "@mantine/core";
import Cover from "../../Common/Cover";
import { useCallback, useEffect, useState } from "react";
import { fetchNui } from "../../../utils/fetchNui";
import "./SearchSong.css";

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
  Playlists: Playlist[];
  setPlaylistActive: (i: number) => void;
  playlistActive: number;
  setOpenedPlaylist: (val: boolean) => void;
}

export default function SearchSong({
  Playlists,
  setPlaylistActive,
  playlistActive,
  setOpenedPlaylist,
}: Props) {
  const [searchLabel, setSearchLabel] = useState("Search song by name or URL");
  const [inputValue, setInputValue] = useState('');
  const [searchResults, setSearchResults] = useState<SearchResult[]>([]);
  const [debounceTimeout, setDebounceTimeout] = useState(0);


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

  useEffect(() => {
    getSearchLabel();
  }, []);

  useEffect(() => {

  }, [inputValue]);

  // Debounce function to delay API calls
//   const debounce = useCallback((func, delay) => {
//     return (...args) => {
//       if (debounceTimeout) {
//         clearTimeout(debounceTimeout);
//       }
//       const timeout = setTimeout(() => {
//         func(...args);
//       }, delay);
//       setDebounceTimeout(timeout);
//     };
//   }, [debounceTimeout]);

//   const fetchSearchResults = async (query) => {
//     try {
//       const response = await axios.get(`YOUR_API_ENDPOINT?q=${query}`);
//       const results = response.data.items.map(v => ({
//         title: v.snippet.title,
//         description: v.snippet.description,
//         thumbnail: v.snippet.thumbnails.default.url,
//         videoId: v.id.videoId,
//         url: `https://www.youtube.com/watch?v=${v.id.videoId}`
//       }));
//       setSearchResults(results);
//     } catch (error) {
//       console.error('Error fetching search results:', error);
//     }
//   };
// Debounce function to delay API calls

const debounce = useCallback((func, delay) => {
    return (...args) => {
      if (debounceTimeout) {
        clearTimeout(debounceTimeout);
      }
      const timeout = setTimeout(() => {
        func(...args);
      }, delay);
      setDebounceTimeout(timeout);
    };
  }, [debounceTimeout]);

const fetchSearchResults = async (query) => {
    try {
      // Simula o delay da API
      await new Promise(resolve => setTimeout(resolve, 500));

      // Dados Mockado
      const mockResponse = {
        data: {
          items: [
            {
              snippet: {
                title: `Mock Song Title 1 for ${query}`,
                description: `Description for Mock Song 1`,
                thumbnails: { default: { url: 'https://via.placeholder.com/40' } }
              },
              id: { videoId: 'mockVideoId1' }
            },
            {
              snippet: {
                title: `Mock Song Title 2 for ${query}`,
                description: `Description for Mock Song 2`,
                thumbnails: { default: { url: 'https://via.placeholder.com/40' } }
              },
              id: { videoId: 'mockVideoId2' }
            },
            {
                snippet: {
                  title: `Mock Song Title 3 for ${query}`,
                  description: `Description for Mock Song 3`,
                  thumbnails: { default: { url: 'https://via.placeholder.com/40' } }
                },
                id: { videoId: 'mockVideoId3' }
              },

              {
                snippet: {
                  title: `Mock Song Title 4 for ${query}`,
                  description: `Description for Mock Song 4`,
                  thumbnails: { default: { url: 'https://via.placeholder.com/40' } }
                },
                id: { videoId: 'mockVideoId4' }
              }
          ]
        }
      };

      const mockResults: SearchResult[] = mockResponse.data.items.map(v => ({
        title: v.snippet.title,
        description: v.snippet.description,
        thumbnail: v.snippet.thumbnails.default.url,
        videoId: v.id.videoId,
        url: `https://www.youtube.com/watch?v=${v.id.videoId}`
      }));
      setSearchResults(mockResults)
    //   setSearchResults(results);
    } catch (error) {
      console.error('Error fetching search results:', error);
    }
  };

  const handleInputChange = (e) => {
    const value = e.target.value;
    setInputValue(value);
    if (value.length >= 3) {
      debounce(() => fetchSearchResults(value), 300)();
    }
  };

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
          />
        </div>
        {/* <div className="addPlaylists">
          <LibraryMenu setOpenedPlaylist={setOpenedPlaylist} />
        </div> */}
   <div className="searchResultContainer">

        {searchResults.map((result, index) => (
          <div className="searchResultItem" key={index}>
            <img src={result.thumbnail} alt={result.title} />
            <h3>{result.title}</h3>
            <p>{result.description}</p>
            <a href={result.url} target="_blank" rel="noopener noreferrer">   

            {/* TODO STATE MUSIC PLAYING*/}
            <PlayerPlay strokeWidth={2} color={"white"} /> 
            </a>
          </div>
        ))}

      </div>
    </div>
  );
}
