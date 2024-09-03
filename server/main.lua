local value = nil
local ytUrl = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=%s&maxResults=%d&key=%s"

local function searchYoutube(text)
    local results = nil
    PerformHttpRequest(string.format(ytUrl, text:gsub(" ", "%%20"), Config.MaxResults, Config.ApiKey),
        function(errorCode, resultData, resultHeaders)
            if resultData then
                local items = json.decode(resultData).items
                for k, v in pairs(items) do
                    if v.id.kind == "youtube#video" then
                        if not results then
                            results = {}
                        end
                        results[#results + 1] = {
                            title = v.snippet.title,
                            description = v.snippet.description,
                            thumbnail = v.snippet.thumbnails.default.url,
                            videoId = v.id.videoId,
                            url = "https://www.youtube.com/watch?v=" .. v.id.videoId
                        }
                    end
                end
            else
                print(json.encode(errorCode))
            end
            if not results then
                results = {}
            end
        end, "GET")
    while results == nil do
        Citizen.Wait(0)
    end
    return results
end

lib.callback.register("apitube:server:search", function(source, text)
    return searchYoutube(text)
end)
