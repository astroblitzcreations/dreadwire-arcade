#!/usr/bin/env python3
"""Small random-looping cabinet jukebox controlled through a Unix socket."""

import json
import os
import random
import re
import signal
import socket
import subprocess
import time
from pathlib import Path

MUSIC_DIR = Path("/home/pi/Music/dreadwire-arcade")
RUNTIME_DIR = Path("/run/dreadwire-music")
SOCKET_PATH = RUNTIME_DIR / "control.sock"
STATE_PATH = RUNTIME_DIR / "state.json"
CONFIG_DIR = Path("/home/pi/.config/dreadwire-music")
CONFIG_PATH = CONFIG_DIR / "config.json"


def display_title(path: Path) -> str:
    title = path.stem
    for prefix in (
        "alexgrohl-", "arpmedia-", "dub_tropic-", "eliza_music-",
        "monume-", "moodmode-", "nveravetyanmusic-", "solarflex-",
        "usefulpix-",
    ):
        if title.lower().startswith(prefix):
            title = title[len(prefix):]
            break
    title = title.replace("-", " ").replace("_", " ")
    words = title.split()
    if words and words[-1].isdigit() and len(words[-1]) >= 5:
        words.pop()
    return " ".join(words).title()


class Jukebox:
    def __init__(self):
        RUNTIME_DIR.mkdir(parents=True, exist_ok=True)
        CONFIG_DIR.mkdir(parents=True, exist_ok=True)
        self.volume = 0.72
        self.enabled = True
        self.paused = False
        self.game_paused = False
        self.game_paused_at = 0.0
        self.was_playing_before_game = False
        self.process = None
        self.current = None
        self.queue = []
        self.load_config()

    def load_config(self):
        try:
            data = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
            self.volume = float(data.get("volume", self.volume))
            self.enabled = bool(data.get("enabled", True))
        except (OSError, ValueError, TypeError):
            pass

    def save_config(self):
        CONFIG_PATH.write_text(
            json.dumps({"volume": self.volume, "enabled": self.enabled}),
            encoding="utf-8",
        )

    def tracks(self):
        return sorted(MUSIC_DIR.glob("*.mp3"), key=lambda item: item.name.lower())

    def refill(self):
        previous = self.current
        self.queue = self.tracks()
        random.SystemRandom().shuffle(self.queue)
        if previous and len(self.queue) > 1 and self.queue[0] == previous:
            self.queue.append(self.queue.pop(0))

    def write_state(self, message=""):
        status = "stopped"
        if self.enabled and self.current:
            status = "paused" if self.paused or self.game_paused else "playing"
        data = {
            "status": status,
            "title": display_title(self.current) if self.current else "No track selected",
            "file": self.current.name if self.current else "",
            "volume": round(self.volume * 100),
            "message": message,
        }
        temporary = STATE_PATH.with_suffix(".tmp")
        temporary.write_text(json.dumps(data), encoding="utf-8")
        temporary.replace(STATE_PATH)

    def terminate(self):
        if self.process and self.process.poll() is None:
            self.process.terminate()
            try:
                self.process.wait(timeout=2)
            except subprocess.TimeoutExpired:
                self.process.kill()
                self.process.wait()
        self.process = None

    def adjust_live_stream(self, delta):
        """Adjust VLC's existing Pulse stream without restarting the song."""
        if not self.process or self.process.poll() is not None or self.paused:
            return
        try:
            listing = subprocess.check_output(
                ["pactl", "list", "sink-inputs"], text=True,
                stderr=subprocess.DEVNULL,
            )
            stream_id = None
            for block in re.split(r"(?=Sink Input #)", listing):
                if f'application.process.id = "{self.process.pid}"' not in block:
                    continue
                match = re.search(r"Sink Input #(\d+)", block)
                if match:
                    stream_id = match.group(1)
                    break
            if stream_id and abs(delta) > 0.0001:
                subprocess.run(
                    ["pactl", "set-sink-input-volume", stream_id, f"{delta * 100:+.0f}%"],
                    check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                )
        except (OSError, subprocess.SubprocessError):
            pass

    def start_next(self):
        if not self.enabled or self.game_paused:
            return
        self.terminate()
        if not self.queue:
            self.refill()
        if not self.queue:
            self.current = None
            self.write_state("No MP3 files found")
            return
        self.current = self.queue.pop(0)
        self.paused = False
        self.start_current()
        self.write_state("Now playing")

    def start_current(self):
        """Start the selected track using the current gain setting."""
        if not self.current or not self.enabled or self.game_paused:
            return
        self.process = subprocess.Popen(
            [
                "/usr/bin/cvlc", "--intf=dummy", "--play-and-exit", "--no-video",
                # Share the cabinet's PipeWire/Pulse sink with EmulationStation
                # and its menu/launch effects.  Opening HDMI through VLC's
                # direct ALSA output is exclusive on this Pi: SDL then blocks
                # forever waiting for its launch sound, so the screen fades to
                # black before runcommand ever starts the selected ROM.
                "--quiet", "--aout=pulse",
                "--audio-resampler=soxr", "--audio-replay-gain-mode=none",
                f"--gain={self.volume:.2f}", str(self.current),
            ],
            stdin=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

    def command(self, command):
        command = command.strip().lower()
        if command.startswith("volume:"):
            previous = self.volume
            try: self.volume = max(0.0, min(1.25, float(command.split(":", 1)[1]) / 100.0))
            except ValueError: return
            self.save_config()
            self.adjust_live_stream(self.volume - previous)
            self.write_state("Volume set")
            return
        if command in ("next", "skip"):
            self.enabled = True
            self.game_paused = False
            self.start_next()
        elif command in ("toggle", "pause"):
            if not self.enabled or not self.process:
                self.enabled = True
                self.game_paused = False
                self.start_next()
            elif self.process.poll() is None:
                if self.paused:
                    self.process.send_signal(signal.SIGCONT)
                else:
                    self.process.send_signal(signal.SIGSTOP)
                self.paused = not self.paused
                self.write_state()
        elif command in ("play", "resume"):
            self.enabled = True
            self.game_paused = False
            if self.process and self.process.poll() is None and self.paused:
                self.process.send_signal(signal.SIGCONT)
                self.paused = False
                self.write_state()
            elif not self.process or self.process.poll() is not None:
                self.start_next()
        elif command == "stop":
            self.enabled = False
            self.paused = False
            self.game_paused = False
            self.terminate()
            self.write_state("Music stopped")
        elif command == "mute":
            if self.process and self.process.poll() is None and not self.paused: self.process.send_signal(signal.SIGSTOP)
            self.paused = True
            self.write_state("Jukebox muted")
        elif command == "unmute":
            self.enabled = True
            if self.process and self.process.poll() is None:
                self.process.send_signal(signal.SIGCONT); self.paused = False; self.write_state("Jukebox unmuted")
            elif not self.game_paused: self.start_next()
        elif command == "gamepause":
            self.was_playing_before_game = self.enabled and not self.paused
            self.game_paused = True
            self.game_paused_at = time.monotonic()
            # HDMI has one hardware playback stream.  Terminate VLC rather than
            # SIGSTOP it so RetroArch can open the device for game audio.
            self.terminate()
            self.write_state("Paused while game is running")
        elif command == "gameresume":
            self.game_paused = False
            self.game_paused_at = 0.0
            if self.was_playing_before_game and self.enabled:
                self.start_next()
            self.was_playing_before_game = False
        elif command in ("volumeup", "volup"):
            previous = self.volume
            self.volume = min(1.25, self.volume + 0.08)
            self.save_config()
            self.adjust_live_stream(self.volume - previous)
            self.write_state("Volume increased")
        elif command in ("volumedown", "voldown"):
            previous = self.volume
            self.volume = max(0.15, self.volume - 0.08)
            self.save_config()
            self.adjust_live_stream(self.volume - previous)
            self.write_state("Volume decreased")
        elif command == "status":
            self.write_state()
        self.save_config()

    def run(self):
        if SOCKET_PATH.exists():
            SOCKET_PATH.unlink()
        control = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
        control.bind(str(SOCKET_PATH))
        os.chmod(SOCKET_PATH, 0o666)
        control.settimeout(0.5)
        self.write_state("Jukebox ready")
        if self.enabled:
            self.start_next()
        while True:
            try:
                command = control.recv(256).decode("utf-8", errors="replace")
                self.command(command)
            except socket.timeout:
                pass
            if (
                self.enabled and not self.paused and not self.game_paused
                and self.process and self.process.poll() is not None
            ):
                self.start_next()
            # A launcher can fail before runcommand's end hook executes.  Do
            # not leave the menu silent forever when no game remains alive.
            if self.game_paused and time.monotonic() - self.game_paused_at >= 8.0:
                game_alive = subprocess.run(
                    [
                        "pgrep", "-f",
                        "/opt/retropie/supplementary/runcommand/runcommand.sh|"
                        "/opt/retropie/emulators/|"
                        "/opt/dreadwire/void-run/void-run.arm64|"
                        "/opt/dreadwire/arena-brawl/arena-brawl[^ ]*|"
                        "/opt/dreadwire/speedbike/speedbike.arm64|"
                        "/opt/dreadwire/goldmaze/goldmaze.arm64",
                    ],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    check=False,
                ).returncode == 0
                if not game_alive:
                    self.game_paused = False
                    self.game_paused_at = 0.0
                    if self.was_playing_before_game and self.enabled:
                        self.start_next()
                    self.was_playing_before_game = False
                    self.write_state("Recovered after failed game launch")
            time.sleep(0.05)


if __name__ == "__main__":
    Jukebox().run()
