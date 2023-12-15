#!/bin/bash

function fetch_videos_from_rss(){
  local rss_feed_url=$1

  # Parse the RSS feed and extract YouTube URLs. deduplicating, as they appear twice for each item
  local youtube_video_ids=($(curl -s "$rss_feed_url" | ggrep -oP 'https://www.youtube.com/watch\?v=\K[^&<"]+' | uniq ) )

  echo "${youtube_video_ids[*]}"
}

function fetch_videos_from_playlist(){
  local playlist_url=$1
  local playlist_video_ids=($(youtube-dl --get-id --playlist-end 5 "$playlist_url" | tac))
  echo "${playlist_video_ids[*]}"
}

function submit_for_conversion(){
  local filename=$1
  local video_id=$2
  local date=$(date +%Y%m%d%H%M%S) # Format date as YYYYMMDDHHMMSS

  # Ask for user confirmation before submitting
  echo "Submit video ID ${video_id} for conversion? (y/n)"
  read -r confirm
  if [[ $confirm == [yY] ]]; then
    echo "{\"id\": \"${video_id}\"}" > "${filename}"
    git add "${filename}" && git commit -m "Add ${filename} for conversion - ${date}" && git push
    echo "Video ID ${video_id} submitted for conversion."
  else
    echo "Video ID ${video_id} not submitted."
  fi
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
  # set -x
    # Assuming these variables are set to the correct URLs for the YouTube playlist and RSS feed:
    playlist_url="${playlists[$i]}"
    rss_url="${urls[$i]}"
    podcast_title="${podcast_names[$i]}"

    # This is a placeholder for the function that fetches video IDs from the playlist and RSS feed.
    # Replace these with the actual calls that fetch video IDs.
    videos_in_rss=( $(fetch_videos_from_rss "$rss_url") )
    videos_in_playlist=( $(fetch_videos_from_playlist "$playlist_url") )

    # The function should compare and find the differences.
    videos_to_convert=()
    for video_id in "${videos_in_playlist[@]}"; do
      if ! [[ " ${videos_in_rss[*]} " =~ " ${video_id} " ]]; then
        if [[ $1 == "--check" ]]; then
          open "https://www.youtube.com/watch?v=${video_id}"
        fi
        submit_for_conversion "${podcast_title}.json" "${video_id}"
      fi
    done
done