#!/usr/bin/env bash
case "$(basename "$0")" in
  01-now-playing.sh) exec /home/pi/RetroPie/retropiemenu/music-now-playing.rp ;;
  02-play-pause.sh) exec /home/pi/RetroPie/retropiemenu/music-play-pause.rp ;;
  03-next-song.sh) exec /home/pi/RetroPie/retropiemenu/music-next.rp ;;
  04-music-louder.sh) exec /home/pi/RetroPie/retropiemenu/music-volume-up.rp ;;
  05-music-softer.sh) exec /home/pi/RetroPie/retropiemenu/music-volume-down.rp ;;
  06-stop-music.sh) exec /home/pi/RetroPie/retropiemenu/music-stop.rp ;;
esac
