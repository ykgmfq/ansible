#!/usr/bin/python3
from argparse import ArgumentParser
from yt_dlp import YoutubeDL

parser = ArgumentParser(description="Download videos.")
parser.add_argument("type", type=str, choices=["playlist", "channel"], help="Type.")
parser.add_argument("url", help="URL.")
args = parser.parse_args()

if args.type == "playlist":
    outtmpl = '%(playlist_index)s_%(playlist_title)s.%(ext)s'
else:
    outtmpl = '%(title)s.%(ext)s'

opts={
        'continue': True,
        'writethumbnail': True,
        'break_on_existing': True,
        'date_after': 'now-7',
        'format': "bv*[ext=mp4]+ba[ext=m4a]/bv*[ext=mp4]+ba/bv*+ba/b",
#        'paths': {'temp':'/tmp'},
        'postprocessors': [{
            'key': 'FFmpegMetadata',
            'add_chapters': True,
            'add_metadata': True,
        }],
        'outtmpl': outtmpl
    }

with YoutubeDL(opts) as ydl:
  ydl.download([args.url])
