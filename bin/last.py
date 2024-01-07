import requests
import subprocess
import re
import sys
import webbrowser
from datetime import datetime

def fetch_videos_from_rss(rss_feed_url):
    print(f"Fetching videos from RSS feed: {rss_feed_url}")
    response = requests.get(rss_feed_url)
    response.raise_for_status()
    youtube_video_ids = list(set(re.findall(r'https://www\.youtube\.com/watch\?v=([^&<"]+)', response.text)))
    print(f"Found {len(youtube_video_ids)} video(s) in RSS feed.")
    return youtube_video_ids

def fetch_videos_from_playlist(playlist_url):
    print(f"Fetching videos from playlist: {playlist_url}")
    command = ['youtube-dl', '--get-id', '--get-title', '--playlist-end', '5', playlist_url]
    output = subprocess.check_output(command).decode()
    lines = output.strip().split('\n')
    playlist_video_info = list(zip(lines[::2], lines[1::2]))
    playlist_video_info.reverse()
    print(f"Found {len(playlist_video_info)} video(s) in playlist.")
    return playlist_video_info

def submit_for_conversion(filename, video_id, video_title):
    date = datetime.now().strftime('%Y%m%d%H%M%S')
    print(f"Preparing to submit video ID {video_id} with title '{video_title}' for conversion.")
    confirm = 'y' if '--no-check' in sys.argv else input(f"Submit video ID {video_id} with title '{video_title}' for conversion? (y/n): ")
    if confirm.lower() == 'y':
        with open(filename, 'w') as file:
            file.write(f'{{"id": "{video_id}", "title": "{video_title}"}}')
        subprocess.run(['git', 'add', filename], check=True)
        commit_message = f"Add {filename} for conversion: {video_title} - {date}"
        subprocess.run(['git', 'commit', '-m', commit_message], check=True)
        subprocess.run(['git', 'push'], check=True)
        print(f"Video ID {video_id} with title '{video_title}' submitted for conversion.")
    else:
        print(f"Submission for video ID {video_id} with title '{video_title}' cancelled by user.")

def main():
    urls = [
        'https://anchor.fm/s/7f9e6388/podcast/rss',
        'https://anchor.fm/s/2d664658/podcast/rss',
        'https://anchor.fm/s/8470a768/podcast/rss',
    ]

    playlists = [
        'https://www.youtube.com/playlist?list=PLoXdlLuaGN8ShASxcE2A4YuSto3AblDmX',
        'https://www.youtube.com/playlist?list=PLoXdlLuaGN8Rou1oTBmKgBhtsYFTyx82I',
        'https://www.youtube.com/playlist?list=PLoXdlLuaGN8REjJ-bjDenWVaUIRhqWyvt',
    ]

    podcast_names = [
        'epicentrismo',
        'tertuliamatinal',
        'circulo',
    ]

    for i, (rss_url, playlist_url, podcast_title) in enumerate(zip(urls, playlists, podcast_names)):
        videos_in_rss = fetch_videos_from_rss(rss_url)
        videos_in_playlist = fetch_videos_from_playlist(playlist_url)
        videos_to_convert = [(video_id, video_title) for video_title, video_id in videos_in_playlist if video_id not in videos_in_rss]

        for video_id, video_title in videos_to_convert:
            if '--no-check' not in sys.argv:
                print(f"Checking video: https://www.youtube.com/watch?v={video_id}")
                webbrowser.open(f"https://www.youtube.com/watch?v={video_id}")
            submit_for_conversion(f"{podcast_title}.json", video_id, video_title)

if __name__ == "__main__":
    main()