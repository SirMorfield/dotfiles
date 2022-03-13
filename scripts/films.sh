#!/bin/bash
find films/000\ films_original/ -type d -exec mkdir -p {} filmsCompressed/{} \;
find films/000\ films_original/ -type f -not -iregex '.*\.\(mkv\|mp4\)' -exec cp -rf {} filmsCompressed/{} \;
find films/000\ films_original/ -type f -iregex '.*\.\(mkv\|mp4\)' -exec ffmpeg -vcodec h264 -y -i {} 'filmsCompressed/{}' \;
