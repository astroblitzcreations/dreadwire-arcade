#!/usr/bin/env bash
case "$(basename "$0")" in
  01-now-playing.sh) exec /home/pi/RetroPie/retropiemenu/music-now-playing.rp ;;
  02-play-pause.sh) exec /usr/local/bin/dreadwire-musicctl.py toggle ;;
  03-next-song.sh) exec /usr/local/bin/dreadwire-musicctl.py next ;;
  04-music-louder.sh) exec /usr/local/bin/dreadwire-musicctl.py volumeup ;;
  05-music-softer.sh) exec /usr/local/bin/dreadwire-musicctl.py volumedown ;;
  06-stop-music.sh) exec /usr/local/bin/dreadwire-musicctl.py stop ;;
esac
