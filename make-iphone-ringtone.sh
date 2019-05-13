#!/bin/bash
# curl https://raw.githubusercontent.com/omerh/scripts/master/make-iphone-ringtone.sh | bash -s [youtube-link]

pip install --upgrade youtube-dl
brew install ffmpeg

mkdir -p /tmp/ring
cd /tmp/ring

youtube-dl -x --audio-format m4a  $1

IFS=$'\n'
for file in `ls`; do 
  echo $file; 
  ffmpeg -t 28 -i "$file" outfile.m4a
  mv outfile.m4a ~/`echo $file|cut -d. -f1`.m4r
  rm -f "$file"
done