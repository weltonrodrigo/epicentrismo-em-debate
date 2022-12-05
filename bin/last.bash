#!/usr/bin/env bash
#


function last {
    url=$1
    titles=$(curl -s $url | ack title | head -3 | tail -1)
    echo "$titles"
}

function clean {
    raw_title=$1
    echo "$(echo "$1" | sed -e 's/.*\[\(.*\)\]\].*/\1/')"
}

function videos {
    url=$1
    data=$(youtube-dl --dump-json "$url" --playlist-items 2 | jq '"\(.title) \(.id)"')
    echo "$data"
}

declare -a  urls=(
    https://anchor.fm/s/7f9e6388/podcast/rss
    https://anchor.fm/s/2d664658/podcast/rss
    https://anchor.fm/s/8470a768/podcast/rss
)

declare -a playlists=(
    'https://www.youtube.com/playlist?list=PLoXdlLuaGN8ShASxcE2A4YuSto3AblDmX'
    'https://www.youtube.com/playlist?list=PLoXdlLuaGN8Rou1oTBmKgBhtsYFTyx82I'
    'https://www.youtube.com/playlist?list=PLoXdlLuaGN8REjJ-bjDenWVaUIRhqWyvt'
)

for i in "${urls[@]}"
do 
    out=$(clean "$(last $i)")
    echo ANCHOR $out
done

for i in "${playlists[@]}"
do 
    out=$(videos $i)
    echo $out
done
