#!/bin/bash

function last {
    url=$1
    title=$(curl -s $url | ack -oP '(?<=<title><!\[CDATA\[).*(?=\]\]></title>)' | sed -n 2p)
    echo "$title"
}

function videos {
    url=$1
    data=$(youtube-dl --dump-json --dateafter now-7day --playlist-end 2 "$url" | jq '. | "\(.title) \(.id)"' |tac )
    echo "$data"
}

declare -a urls=(
    https://anchor.fm/s/7f9e6388/podcast/rss
    https://anchor.fm/s/2d664658/podcast/rss
    https://anchor.fm/s/8470a768/podcast/rss
)

declare -a playlists=(
    'https://www.youtube.com/playlist?list=PLoXdlLuaGN8ShASxcE2A4YuSto3AblDmX'
    'https://www.youtube.com/playlist?list=PLoXdlLuaGN8Rou1oTBmKgBhtsYFTyx82I'
    'https://www.youtube.com/playlist?list=PLoXdlLuaGN8REjJ-bjDenWVaUIRhqWyvt'
)

declare -a podcast_names=(
    'epicentrismo'
    'tertuliamatinal'
    'circulo'
)

for i in "${!urls[@]}"; do
    podcast_title=$(last "${urls[$i]}")
    video_data=$(videos "${playlists[$i]}")
    IFS=$'\n' read -d '' -a video_list <<< "${video_data}"

    echo $video_data

    found=0
    oldest_video=""
    for video in "${video_list[@]}"; do
        video_id=$(echo $video | awk '{print $NF}')
        video_title=$(echo $video | awk '{$NF=""; print $0}')

        # echo $video $video_id $video_title

        if [ "$podcast_title" == "$video_title" ]; then
            found=1
            echo "Match: $podcast_title == $video_title"
            break
        else
            if [ -z "$oldest_video" ]; then
                oldest_video=$video
            fi
        fi
    done

    if [ "$found" -eq 0 ]; then
        echo "Mismatch: $podcast_title $video_title"
        echo "{\"id\": \"$(echo ${oldest_video} | awk '{print $NF}')}" > "${podcast_names[$i]}.json"
        
        # check if --open argument is provided to the script
        if [[ $1 == "--open" ]]; then
            video_id=$(echo $oldest_video | awk '{print $NF}')
            # use `open` command to open the video in the browser
            open "https://www.youtube.com/watch?v=${video_id}"
        fi
    fi

done