import requests
import youtube_dl
import json
import re
from xml.etree import ElementTree

def last(url):
    response = requests.get(url)
    xml_str = response.text
    tree = ElementTree.fromstring(xml_str)
    title = tree.find('.//channel/item/title').text
    return title

def videos(url):
    ydl_opts = {
        'playlistend': 4,
        'dateafter': 'now-7day',
        'format': 'json',
    }

    with youtube_dl.YoutubeDL(ydl_opts) as ydl:
        video_data_list = ydl.extract_info(url, download=False)['entries']

        titles_and_ids = []
        for video in video_data_list:
            title = video['title']
            video_id = video['id']
            titles_and_ids.append((title, video_id))

        return titles_and_ids[::-1]  # Reverse the list to start from the oldest videos

urls = [
    'https://anchor.fm/s/7f9e6388/podcast/rss',
    'https://anchor.fm/s/2d664658/podcast/rss',
    'https://anchor.fm/s/8470a768/podcast/rss',
]

playlists = [