#!/usr/bin/env python3
"""Dreadwire Arcade Remote: PWA, virtual gamepad, admin, uploads and telemetry."""

import asyncio
import hashlib
import hmac
import json
import os
import re
import secrets
import shutil
import socket
import sqlite3
import subprocess
import time
import urllib.request
from io import BytesIO
from urllib.parse import quote
from pathlib import Path

from aiohttp import web, WSMsgType
from evdev import UInput, InputDevice, ecodes as e, AbsInfo, list_devices
from PIL import Image
import psutil

ROOT = Path("/opt/dreadwire/companion")
WEB = ROOT / "web"
CONFIG = ROOT / "config.json"
TOKENS: dict[str, dict] = {}
STARTED = time.monotonic()
REMOTE_INPUT_ENABLED = os.environ.get("DREADWIRE_REMOTE_INPUT", "1") == "1"
STATE_DIR = Path("/var/lib/dreadwire-companion")
BATTERY_STATE = STATE_DIR / "battery.json"
USER_DB = STATE_DIR / "users.db"
SETTINGS_STATE = STATE_DIR / "settings.json"
FAN_STATE = Path("/run/dreadwire-argon-fan.json")
FAN_CONFIG = STATE_DIR / "fan.json"
ARCADE_MODE_STATE = STATE_DIR / "mode.json"
AUDIO_CONFIG = Path("/home/pi/.config/dreadwire-audio.json")
WS_CLIENTS = set()
PARTY_CLIENTS = set()
PARTY_CONNECTIONS = {}
PARTY_QUEUE = []
PARTY_CHAT = []
GAME_SELECTION = {}
SCREEN_LOCK = asyncio.Lock()
PACKAGE_VERSION = "1.1.2"
UPDATE_CONFIG = Path("/etc/dreadwire/update.json")

UPLOADS = {
    "music": Path("/home/pi/Music/dreadwire-arcade"),
    "screensaver-images": Path("/home/pi/ArcadeShare/Screensavers/Images and Thumbnails"),
    "screensaver-videos": Path("/home/pi/ArcadeShare/Screensavers/Videos"),
    "theme": Path("/home/pi/ArcadeShare/Theme/Incoming"),
}
ROM_ROOT = Path("/home/pi/RetroPie/roms")
SAFE_SYSTEM = re.compile(r"^[a-zA-Z0-9_-]{1,32}$")
MEDIA_CATEGORIES = {
    "images": UPLOADS["screensaver-images"],
    "videos": UPLOADS["screensaver-videos"],
    "music": UPLOADS["music"],
}
MEDIA_EXTENSIONS = {
    "images": {".png",".jpg",".jpeg",".webp",".gif"},
    "videos": {".mp4",".webm",".mkv"},
    "music": {".mp3",".wav",".ogg"},
}
MIME_TYPES = {".png":"image/png",".jpg":"image/jpeg",".jpeg":"image/jpeg",".webp":"image/webp",".gif":"image/gif",
              ".mp4":"video/mp4",".webm":"video/webm",".mkv":"video/x-matroska",".mp3":"audio/mpeg",".wav":"audio/wav",".ogg":"audio/ogg"}


def settings():
    base={"media_enabled":True,"uploads_enabled":True,"large_uploads":False,"normal_limit_mb":100,
          "party_launch_policy":"any_queued"}
    try: base.update(json.loads(SETTINGS_STATE.read_text()))
    except (OSError,ValueError,TypeError): pass
    return base


def write_settings(data):
    STATE_DIR.mkdir(parents=True,exist_ok=True)
    temp=SETTINGS_STATE.with_suffix(".tmp"); temp.write_text(json.dumps(data,indent=2)+"\n"); temp.replace(SETTINGS_STATE)


def nmcli(*args, timeout=25):
    return subprocess.run(["nmcli", *args], text=True, capture_output=True, timeout=timeout, check=False)


def split_nmcli(line):
    fields=[]; field=[]; escaped=False
    for char in line:
        if escaped: field.append(char); escaped=False
        elif char == "\\": escaped=True
        elif char == ":": fields.append("".join(field)); field=[]
        else: field.append(char)
    fields.append("".join(field))
    return fields


def load_config():
    return json.loads(CONFIG.read_text())


CFG = load_config()


def db():
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(USER_DB)
    conn.row_factory = sqlite3.Row
    conn.executescript("""
      CREATE TABLE IF NOT EXISTS users(
        id INTEGER PRIMARY KEY, username TEXT UNIQUE COLLATE NOCASE,
        email TEXT UNIQUE COLLATE NOCASE, salt TEXT, password_hash TEXT,
        created REAL NOT NULL, last_login REAL, login_count INTEGER DEFAULT 0);
      CREATE TABLE IF NOT EXISTS layouts(
        user_id INTEGER NOT NULL, preset TEXT NOT NULL, data TEXT NOT NULL,
        updated REAL NOT NULL, PRIMARY KEY(user_id,preset));
      CREATE TABLE IF NOT EXISTS activity(
        id INTEGER PRIMARY KEY, at REAL NOT NULL, user_id INTEGER,
        actor TEXT NOT NULL, event TEXT NOT NULL, detail TEXT);
      CREATE TABLE IF NOT EXISTS high_scores(
        id INTEGER PRIMARY KEY, user_id INTEGER, username TEXT NOT NULL,
        game_title TEXT NOT NULL COLLATE NOCASE, score INTEGER NOT NULL,
        created REAL NOT NULL);
      CREATE INDEX IF NOT EXISTS high_scores_game_score
        ON high_scores(game_title,score DESC,created ASC);
      CREATE TABLE IF NOT EXISTS party_queue(
        id INTEGER PRIMARY KEY, user_key TEXT UNIQUE NOT NULL, name TEXT NOT NULL,
        state TEXT NOT NULL DEFAULT 'waiting', joined REAL NOT NULL,
        invited_until REAL, accepted REAL);
      CREATE TABLE IF NOT EXISTS party_chat(
        id INTEGER PRIMARY KEY, user_key TEXT, name TEXT NOT NULL,
        message TEXT NOT NULL, created REAL NOT NULL);
    """)
    columns={row[1] for row in conn.execute("PRAGMA table_info(party_queue)")}
    if "last_seen" not in columns:
        conn.execute("ALTER TABLE party_queue ADD COLUMN last_seen REAL")
        conn.execute("UPDATE party_queue SET last_seen=joined WHERE last_seen IS NULL")
    return conn


def make_hash(password):
    if not password: return (None, None)
    salt = secrets.token_bytes(16)
    digest = hashlib.pbkdf2_hmac("sha256", password.encode(), salt, 240_000)
    return salt.hex(), digest.hex()


def user_password_ok(row, password):
    if not row["password_hash"]: return not password
    if not password: return False
    found = hashlib.pbkdf2_hmac("sha256", password.encode(), bytes.fromhex(row["salt"]), 240_000)
    return hmac.compare_digest(found.hex(), row["password_hash"])


def log_event(actor, event, detail="", user_id=None):
    with db() as conn:
        conn.execute("INSERT INTO activity(at,user_id,actor,event,detail) VALUES(?,?,?,?,?)",
                     (time.time(), user_id, actor[:80], event[:80], str(detail)[:500]))


def password_ok(password: str) -> bool:
    salt = bytes.fromhex(CFG["salt"])
    found = hashlib.pbkdf2_hmac("sha256", password.encode(), salt, 240_000)
    return hmac.compare_digest(found.hex(), CFG["password_hash"])


def request_token(request):
    auth = request.headers.get("Authorization", "")
    if auth.startswith("Bearer "):
        return auth[7:]
    return request.query.get("token", "")


def authorized(request):
    token = request_token(request)
    session = TOKENS.get(token)
    if not session or session["expires"] <= time.time():
        TOKENS.pop(token, None)
        return False
    session["expires"] = time.time() + 86400 * 7
    return session


async def require(request, role=None):
    session = authorized(request)
    if not session:
        raise web.HTTPUnauthorized(text="Login required")
    if role and session.get("role") != role:
        raise web.HTTPForbidden(text="Admin login required")
    return session


class MobilePad:
    BUTTONS = {
        "a": e.BTN_SOUTH, "b": e.BTN_EAST, "x": e.BTN_NORTH, "y": e.BTN_WEST,
        "l1": e.BTN_TL, "r1": e.BTN_TR, "l2": e.BTN_TL2, "r2": e.BTN_TR2,
        "select": e.BTN_SELECT, "start": e.BTN_START,
        "l3": e.BTN_THUMBL, "r3": e.BTN_THUMBR,
    }
    def __init__(self, player=1):
        self.player = player
        axes = {
            e.ABS_X: AbsInfo(0, -32768, 32767, 128, 128, 0),
            e.ABS_Y: AbsInfo(0, -32768, 32767, 128, 128, 0),
            e.ABS_RX: AbsInfo(0, -32768, 32767, 128, 128, 0),
            e.ABS_RY: AbsInfo(0, -32768, 32767, 128, 128, 0),
            e.ABS_HAT0X: AbsInfo(0, -1, 1, 0, 0, 0),
            e.ABS_HAT0Y: AbsInfo(0, -1, 1, 0, 0, 0),
        }
        direction_keys = [e.KEY_LEFT, e.KEY_RIGHT, e.KEY_UP, e.KEY_DOWN,
                          e.KEY_ENTER, e.KEY_ESC, e.KEY_SPACE, e.KEY_S]
        self.ui = UInput({e.EV_KEY: list(self.BUTTONS.values()), e.EV_ABS: axes},
                         name=f"Dreadwire Player {player}", vendor=0x4457,
                         product=player, version=1)
        # Keep navigation keys on a distinct evdev keyboard. EmulationStation
        # classifies mixed axis/key devices as joysticks and ignores KEY_UP,
        # while a dedicated keyboard is handled reliably by every menu.
        self.keyboard = UInput({e.EV_KEY: direction_keys},
                               name=f"Dreadwire Remote Keyboard P{player}", vendor=0x4457,
                               product=0x0100 + player, version=1)
        self.pressed = set()
        self.pressed_at = {}
        self.direction_pressed = set()

    def tap_key(self, code):
        self.keyboard.write(e.EV_KEY, code, 1)
        self.keyboard.syn()
        # RetroPie's SDL launcher polls once per video frame; an immediate
        # press/release can occur entirely between polls and be missed.
        time.sleep(.12)
        self.keyboard.write(e.EV_KEY, code, 0)
        self.keyboard.syn()

    def tap_direction(self, x, y):
        """Tap both the virtual stick and hat for EmulationStation menus."""
        self.ui.write(e.EV_ABS, e.ABS_X, x * 32767)
        self.ui.write(e.EV_ABS, e.ABS_Y, y * 32767)
        self.ui.write(e.EV_ABS, e.ABS_HAT0X, x)
        self.ui.write(e.EV_ABS, e.ABS_HAT0Y, y)
        self.ui.syn(); time.sleep(.16)
        for axis in (e.ABS_X,e.ABS_Y,e.ABS_HAT0X,e.ABS_HAT0Y): self.ui.write(e.EV_ABS,axis,0)
        self.ui.syn()

    def emit_directions(self, x, y):
        """Mirror directions as arrow keys for frontend compatibility."""
        wanted = set()
        if x < -0.45: wanted.add(e.KEY_LEFT)
        if x > 0.45: wanted.add(e.KEY_RIGHT)
        if y < -0.45: wanted.add(e.KEY_UP)
        if y > 0.45: wanted.add(e.KEY_DOWN)
        for code in self.direction_pressed - wanted:
            self.keyboard.write(e.EV_KEY, code, 0)
        for code in wanted - self.direction_pressed:
            self.keyboard.write(e.EV_KEY, code, 1)
        self.direction_pressed = wanted
        self.keyboard.syn()

    def emit(self, message):
        kind = message.get("type")
        if kind == "button" and message.get("code") in self.BUTTONS:
            code = self.BUTTONS[message["code"]]
            value = 1 if message.get("pressed") else 0
            if value: self.pressed_at[code] = time.monotonic()
            else: self.pressed_at.pop(code, None)
            self.ui.write(e.EV_KEY, code, value)
            (self.pressed.add if value else self.pressed.discard)(code)
            # EmulationStation always consumes its keyboard profile, even when
            # another physical controller owns Player 1. Keep frontend actions
            # reliable while the virtual joypad remains available to games.
            if current_game() is None:
                menu_key = {
                    "a": e.KEY_ENTER, "start": e.KEY_ENTER,
                    "b": e.KEY_ESC, "x": e.KEY_SPACE, "y": e.KEY_S,
                }.get(message["code"])
                if menu_key is not None:
                    self.keyboard.write(e.EV_KEY, menu_key, value)
                    self.keyboard.syn()
        elif kind == "dpad":
            # Emit both a conventional D-pad hat and left-stick axes.  Some
            # RetroPie frontends/cores listen only to one representation, so
            # this keeps the touch D-pad usable everywhere (including themes
            # such as SNES that intentionally hide the analog stick).
            x = max(-1, min(1, int(message.get("x", 0))))
            y = max(-1, min(1, int(message.get("y", 0))))
            self.ui.write(e.EV_ABS, e.ABS_HAT0X, x)
            self.ui.write(e.EV_ABS, e.ABS_HAT0Y, y)
            self.ui.write(e.EV_ABS, e.ABS_X, x * 32767)
            self.ui.write(e.EV_ABS, e.ABS_Y, y * 32767)
            self.emit_directions(x, y)
        elif kind == "axis":
            x = max(-1.0, min(1.0, float(message.get("x", 0))))
            y = max(-1.0, min(1.0, float(message.get("y", 0))))
            self.ui.write(e.EV_ABS, e.ABS_X, int(x * 32767))
            self.ui.write(e.EV_ABS, e.ABS_Y, int(y * 32767))
            self.emit_directions(x, y)
        self.ui.syn()

    def release(self):
        for code in tuple(self.pressed):
            self.ui.write(e.EV_KEY, code, 0)
        self.pressed_at.clear()
        for code in tuple(self.direction_pressed):
            self.keyboard.write(e.EV_KEY, code, 0)
        for axis in (e.ABS_X, e.ABS_Y, e.ABS_RX, e.ABS_RY, e.ABS_HAT0X, e.ABS_HAT0Y):
            self.ui.write(e.EV_ABS, axis, 0)
        self.pressed.clear(); self.direction_pressed.clear(); self.ui.syn(); self.keyboard.syn()


class DisabledPad:
    """No-op pad used when the web app runs without virtual input devices."""
    def __init__(self):
        self.pressed_at = {}
    def emit(self, _message): pass
    def release(self): pass
    def tap_key(self, _code): pass
    def tap_direction(self, _x, _y): pass


PADS = [MobilePad(player) for player in range(1, 5)] if REMOTE_INPUT_ENABLED else [DisabledPad() for _ in range(4)]
PAD = PADS[0]

LEGACY_BUTTONS = {
    e.BTN_TRIGGER: e.BTN_SOUTH, e.BTN_THUMB: e.BTN_EAST,
    e.BTN_THUMB2: e.BTN_NORTH, e.BTN_TOP: e.BTN_WEST,
    e.BTN_TOP2: e.BTN_TL, e.BTN_PINKIE: e.BTN_TR,
    e.BTN_BASE: e.BTN_TL2, e.BTN_BASE2: e.BTN_TR2,
    e.BTN_BASE3: e.BTN_SELECT, e.BTN_BASE4: e.BTN_START,
    e.BTN_BASE5: e.BTN_THUMBL, e.BTN_BASE6: e.BTN_THUMBR,
}
STANDARD_BUTTONS = set(MobilePad.BUTTONS.values())
PHYSICAL_PLAYER = {
    "DragonRise Inc. Generic USB Joystick": 1,
    "USB gamepad": 2,
    "Microsoft X-Box 360 pad": 2,
}
GAME_ACTIVE_CACHE = {"checked": 0.0, "active": False}

def game_active_cached():
    now = time.monotonic()
    if now - GAME_ACTIVE_CACHE["checked"] > 2.0:
        GAME_ACTIVE_CACHE["checked"] = now
        GAME_ACTIVE_CACHE["active"] = bool(current_game())
    return GAME_ACTIVE_CACHE["active"]

def normalize_axis(device, code, value):
    if code in (e.ABS_HAT0X, e.ABS_HAT0Y): return max(-1, min(1, value))
    info = device.absinfo(code)
    if not info or info.max == info.min: return 0
    return max(-32768, min(32767, round((value-info.min)*65535/(info.max-info.min)-32768)))

async def mirror_physical_controller(path, player):
    device = InputDevice(path); pad = PADS[player-1]
    last_axes = {}
    try:
        async for event in device.async_read_loop():
            if not game_active_cached():
                if event.type == e.EV_ABS: await asyncio.sleep(.01)
                continue
            if event.type == e.EV_KEY:
                code = LEGACY_BUTTONS.get(event.code, event.code)
                if code in STANDARD_BUTTONS:
                    pad.ui.write(e.EV_KEY, code, 1 if event.value else 0); pad.ui.syn()
            elif event.type == e.EV_ABS and event.code in (e.ABS_X,e.ABS_Y,e.ABS_RX,e.ABS_RY,e.ABS_HAT0X,e.ABS_HAT0Y):
                value=normalize_axis(device,event.code,event.value)
                # Cheap USB encoders can chatter around center continuously.
                # Suppress tiny changes without making deliberate movement lag.
                threshold=0 if event.code in (e.ABS_HAT0X,e.ABS_HAT0Y) else 700
                if abs(value-last_axes.get(event.code,0)) >= threshold or value in (-32768,0,32767):
                    last_axes[event.code]=value
                    pad.ui.write(e.EV_ABS,event.code,value); pad.ui.syn()
                await asyncio.sleep(.003)
    except (OSError, asyncio.CancelledError): pass

async def physical_controller_context(app):
    if not REMOTE_INPUT_ENABLED:
        yield
        return
    tasks = {}
    async def scanner():
        while True:
            found=set()
            for path in Path("/dev/input").glob("event*"):
                try:
                    device=InputDevice(str(path)); name=" ".join(device.name.split()); device.close()
                except OSError: continue
                player=PHYSICAL_PLAYER.get(name)
                if player:
                    found.add(str(path))
                    if str(path) not in tasks or tasks[str(path)].done():
                        tasks[str(path)]=asyncio.create_task(mirror_physical_controller(str(path),player))
            for path in set(tasks)-found: tasks.pop(path).cancel()
            await asyncio.sleep(2)
    scan_task=asyncio.create_task(scanner())
    yield
    scan_task.cancel()
    for task in tasks.values(): task.cancel()


def run(*args):
    return subprocess.run(args, text=True, capture_output=True, timeout=12, check=False)


def text_file(path, default=""):
    try: return Path(path).read_text().strip()
    except OSError: return default


def temperature():
    try: return round(int(text_file("/sys/class/thermal/thermal_zone0/temp")) / 1000, 1)
    except (ValueError, TypeError): return None


def battery():
    for supply in Path("/sys/class/power_supply").glob("*"):
        if text_file(supply / "type").lower() == "battery":
            try: return {"available": True, "percent": int(text_file(supply / "capacity")), "name": supply.name}
            except ValueError: pass
    try:
        state = json.loads(BATTERY_STATE.read_text())
        elapsed = max(0, time.time() - float(state["updated"]))
        same_boot = state.get("boot_id") == text_file("/proc/sys/kernel/random/boot_id")
        rate = state.get("rate_per_hour")
        percent = float(state["percent"])
        if same_boot and rate:
            percent = max(0, percent - float(rate) * elapsed / 3600)
        remaining = percent / float(rate) if rate else None
        return {"available": True, "manual": True, "percent": round(percent, 1),
                "entered_percent": state["percent"], "updated": state["updated"],
                "rate_per_hour": round(rate, 2) if rate else None,
                "remaining_hours": round(remaining, 2) if remaining is not None else None,
                "learning": not bool(rate), "name": "INIU BI-B5 (manual calibration)"}
    except (OSError, ValueError, KeyError, TypeError):
        return {"available": False, "manual": True, "reason": "Enter the percentage shown on the INIU BI-B5 display to begin runtime calibration"}


def _detect_current_game():
    for proc in psutil.process_iter(["name", "cmdline"]):
        cmd = " ".join(proc.info.get("cmdline") or [])
        if proc.info.get("name") == "retroarch":
            roms = [part for part in (proc.info.get("cmdline") or []) if "/roms/" in part]
            return Path(roms[-1]).stem if roms else "RetroArch game"
        if "void-run.arm64" in cmd: return "Void Run"
        if "speedbike.arm64" in cmd: return "Speedbike"
        if "goldmaze.arm64" in cmd: return "Trippy Gold Maze"
    return None


CURRENT_GAME_DETAIL_CACHE = {"checked": 0.0, "value": None}
def current_game():
    """Return the active game without repeatedly walking /proc for every frame/input."""
    now = time.monotonic()
    if now - CURRENT_GAME_DETAIL_CACHE["checked"] > 2.0:
        CURRENT_GAME_DETAIL_CACHE["checked"] = now
        CURRENT_GAME_DETAIL_CACHE["value"] = _detect_current_game()
    return CURRENT_GAME_DETAIL_CACHE["value"]


def mobile_js_index(player=1):
    for js in Path("/sys/class/input").glob("js*"):
        if text_file(js / "device/name") == f"Dreadwire Player {player}":
            return int(js.name[2:])
    return None


def master_volume():
    result=run("runuser","-u","pi","--","pactl","get-sink-volume","@DEFAULT_SINK@").stdout
    match=re.search(r"(\d+)%",result)
    return int(match.group(1)) if match else None

def audio_settings():
    value={"menu_volume":70,"menu_muted":False}
    try: value.update(json.loads(AUDIO_CONFIG.read_text()))
    except (OSError,ValueError,TypeError): pass
    music={}
    try: music=json.loads(text_file("/run/dreadwire-music/state.json","{}"))
    except ValueError: pass
    muted="yes" in run("runuser","-u","pi","--","pactl","get-sink-mute","@DEFAULT_SINK@").stdout.lower()
    return {**value,"master_volume":master_volume(),"master_muted":muted,"music_volume":int(music.get("volume",0)),"music_muted":music.get("status")=="paused"}

async def audio_control(request):
    await require(request,"admin")
    if request.method=="GET": return web.json_response(audio_settings())
    data=await request.json(); target=str(data.get("target","")); volume=max(0,min(125,int(data.get("volume",0)))); muted=bool(data.get("muted",False))
    if target=="master":
        run("runuser","-u","pi","--","pactl","set-sink-volume","@DEFAULT_SINK@",f"{volume}%")
        run("runuser","-u","pi","--","pactl","set-sink-mute","@DEFAULT_SINK@","1" if muted else "0")
    elif target=="music":
        run("/usr/local/bin/dreadwire-musicctl.py",f"volume:{volume}"); run("/usr/local/bin/dreadwire-musicctl.py","mute" if muted else "unmute")
    elif target=="menu":
        AUDIO_CONFIG.parent.mkdir(parents=True,exist_ok=True); AUDIO_CONFIG.write_text(json.dumps({"menu_volume":min(100,volume),"menu_muted":muted},indent=2)+"\n"); os.chown(AUDIO_CONFIG,1000,1000)
    else: raise web.HTTPBadRequest(text="Unknown audio channel")
    return web.json_response({"ok":True,**audio_settings()})


async def index(_): return web.FileResponse(WEB / "index.html")


async def login(request):
    data = await request.json()
    username = str(data.get("username", "")).strip()
    password = str(data.get("password", ""))
    role, user_id, display = "user", None, username
    if username == CFG.get("username", "admin"):
        if not password_ok(password): raise web.HTTPUnauthorized(text="Invalid login")
        role, display = "admin", "Administrator"
    else:
        with db() as conn:
            row = conn.execute("SELECT * FROM users WHERE username=? OR email=?", (username, username)).fetchone()
            if not row or not user_password_ok(row, password): raise web.HTTPUnauthorized(text="Invalid login")
            user_id, display = row["id"], row["username"] or row["email"]
            conn.execute("UPDATE users SET last_login=?,login_count=login_count+1 WHERE id=?", (time.time(), user_id))
        log_event(display, "login", user_id=user_id)
    token = secrets.token_urlsafe(32)
    TOKENS[token] = {"expires": time.time()+86400*7, "role": role, "user_id": user_id, "name": display}
    return web.json_response({"token": token, "name": display, "role": role})


async def guest(request):
    token = secrets.token_urlsafe(32)
    name = "Guest-" + token[:5]
    TOKENS[token] = {"expires": time.time()+86400, "role": "guest", "user_id": None, "name": name}
    log_event(name, "guest-session")
    return web.json_response({"token": token, "name": "Guest", "role": "guest"})


async def register(request):
    data = await request.json(); username = str(data.get("username", "")).strip()[:40]
    email = str(data.get("email", "")).strip()[:120] or None
    password = str(data.get("password", ""))
    if not username: raise web.HTTPBadRequest(text="Choose a username")
    if not re.fullmatch(r"[A-Za-z0-9_. -]{2,40}", username): raise web.HTTPBadRequest(text="Username contains unsupported characters")
    if email and ("@" not in email or len(email) < 5): raise web.HTTPBadRequest(text="Enter a valid email or leave it blank")
    salt, digest = make_hash(password)
    try:
        with db() as conn:
            cur = conn.execute("INSERT INTO users(username,email,salt,password_hash,created,last_login,login_count) VALUES(?,?,?,?,?,?,1)",
                               (username,email,salt,digest,time.time(),time.time()))
            user_id = cur.lastrowid
    except sqlite3.IntegrityError: raise web.HTTPConflict(text="That username or email is already registered")
    log_event(username, "registered", "password-protected" if password else "no-password", user_id)
    token = secrets.token_urlsafe(32)
    TOKENS[token] = {"expires": time.time()+86400*7, "role":"user", "user_id":user_id, "name":username}
    return web.json_response({"token":token,"name":username,"role":"user"})


async def me(request):
    s = await require(request)
    return web.json_response({k:s.get(k) for k in ("role","user_id","name")})


async def logout(request):
    token=request_token(request); session=TOKENS.pop(token,None)
    if session:
        key=str(session.get("user_id") or session["name"])
        with db() as conn: conn.execute("DELETE FROM party_queue WHERE user_key=?",(key,))
        log_event(session["name"],"logout",user_id=session.get("user_id"))
        await broadcast_party()
    return web.json_response({"ok":True})


async def profile_layout(request):
    s = await require(request); preset = request.match_info["preset"]
    if not re.fullmatch(r"[a-z0-9_-]{1,24}", preset): raise web.HTTPBadRequest()
    if request.method == "GET":
        if not s.get("user_id"): return web.json_response({"layout":None})
        with db() as conn: row=conn.execute("SELECT data FROM layouts WHERE user_id=? AND preset=?",(s["user_id"],preset)).fetchone()
        return web.json_response({"layout":json.loads(row["data"]) if row else None})
    if not s.get("user_id"): raise web.HTTPBadRequest(text="Create a profile to sync layouts")
    data = await request.json(); encoded=json.dumps(data.get("layout",{}),separators=(",",":"))
    if len(encoded)>20000: raise web.HTTPBadRequest(text="Layout is too large")
    with db() as conn:
        conn.execute("INSERT INTO layouts(user_id,preset,data,updated) VALUES(?,?,?,?) ON CONFLICT(user_id,preset) DO UPDATE SET data=excluded.data,updated=excluded.updated",(s["user_id"],preset,encoded,time.time()))
    log_event(s["name"], "layout-saved", preset, s["user_id"])
    return web.json_response({"ok":True})


async def admin_users(request):
    await require(request,"admin")
    with db() as conn:
        users=[dict(r) for r in conn.execute("SELECT id,username,email,created,last_login,login_count,(password_hash IS NOT NULL) AS protected FROM users ORDER BY last_login DESC")]
        activity=[dict(r) for r in conn.execute("SELECT at,actor,event,detail FROM activity ORDER BY id DESC LIMIT 100")]
    return web.json_response({"users":users,"activity":activity})


async def admin_reset(request):
    await require(request,"admin"); data=await request.json(); user_id=int(data.get("user_id",0)); password=str(data.get("password",""))
    salt,digest=make_hash(password)
    with db() as conn:
        row=conn.execute("SELECT username FROM users WHERE id=?",(user_id,)).fetchone()
        if not row: raise web.HTTPNotFound(text="User not found")
        conn.execute("UPDATE users SET salt=?,password_hash=? WHERE id=?",(salt,digest,user_id))
    log_event("admin","password-reset",row["username"],user_id)
    return web.json_response({"ok":True})


async def status(request):
    await require(request)
    disk = psutil.disk_usage("/"); memory = psutil.virtual_memory()
    music = {}
    try: music = json.loads(text_file("/run/dreadwire-music/state.json", "{}"))
    except ValueError: pass
    fan = {}
    try: fan = json.loads(text_file(FAN_STATE, "{}"))
    except ValueError: pass
    throttled = run("vcgencmd", "get_throttled").stdout.strip()
    try: throttle_value=int(throttled.split("=")[-1],16)
    except ValueError: throttle_value=0
    return web.json_response({
        "hostname": socket.gethostname(), "ip": request.host.split(":")[0],
        "uptime": int(time.time() - psutil.boot_time()), "temperature": temperature(),
        "cpu": psutil.cpu_percent(interval=.08), "load": list(os.getloadavg()),
        "memory": {"used": memory.used, "total": memory.total, "percent": memory.percent},
        "disk": {"used": disk.used, "total": disk.total, "free": disk.free, "percent": disk.percent},
        "game": current_game(), "music": music, "battery": battery(), "fan": fan,
        "throttled": throttled, "power_status": "GOOD" if throttle_value == 0 else "CHECK POWER",
        "mobile_gamepad_index": mobile_js_index(),
        "player_slots": [mobile_js_index(player) for player in range(1,5)], "master_volume": master_volume(),
        "connected_controllers": len(WS_CLIENTS),
        "active_sessions": sum(1 for s in TOKENS.values() if s["expires"] > time.time()),
        "load_percent": round(os.getloadavg()[0] / max(1, os.cpu_count()) * 100, 1),
    })


def set_config_line(path, key, value):
    path = Path(path); content = path.read_text()
    pattern = re.compile(rf"^\s*{re.escape(key)}\s*=.*$", re.MULTILINE)
    line = f'{key} = "{value}"'
    content = pattern.sub(line, content) if pattern.search(content) else content.rstrip() + "\n" + line + "\n"
    temp = path.with_suffix(path.suffix + ".mobile.tmp"); temp.write_text(content); temp.replace(path)


def capture_screen_jpeg():
    """Read the DRM framebuffer and return a phone-sized upright JPEG."""
    width, height = 1024, 768
    with open("/dev/fb0", "rb", buffering=0) as framebuffer:
        pixels = framebuffer.read(width * height * 2)
    if len(pixels) != width * height * 2:
        raise RuntimeError("Framebuffer is temporarily unavailable")
    image = Image.frombytes("RGB", (width, height), pixels, "raw", "BGR;16")
    image = image.transpose(Image.Transpose.ROTATE_270)
    image.thumbnail((432, 576), Image.Resampling.BILINEAR)
    output = BytesIO()
    image.save(output, "JPEG", quality=62, optimize=False)
    return output.getvalue()


DISPLAY_TRANSITION_CACHE = {"checked": 0.0, "value": False}


def display_transition_active():
    """True while runcommand/X11 is taking ownership of the cabinet display."""
    now = time.monotonic()
    if now - DISPLAY_TRANSITION_CACHE["checked"] < .15:
        return DISPLAY_TRANSITION_CACHE["value"]
    DISPLAY_TRANSITION_CACHE["checked"] = now
    active = False
    for proc in psutil.process_iter(["name", "cmdline"]):
        name = (proc.info.get("name") or "").lower()
        cmd = " ".join(proc.info.get("cmdline") or []).lower()
        if name in {"runcommand.sh", "xinit"} or "runcommand.sh" in cmd:
            active = True
            break
    DISPLAY_TRANSITION_CACHE["value"] = active
    return active


async def screen_frame(request):
    await require(request)
    async with SCREEN_LOCK:
        try:
            jpeg = await asyncio.to_thread(capture_screen_jpeg)
        except (OSError, RuntimeError) as error:
            raise web.HTTPServiceUnavailable(text=str(error))
    return web.Response(body=jpeg, content_type="image/jpeg", headers={
        "Cache-Control": "no-store, no-cache, must-revalidate",
        "Pragma": "no-cache",
    })


async def screen_stream(request):
    """Stream the active DRM/KMS plane, including EmulationStation and games."""
    await require(request)
    if SCREEN_LOCK.locked():
        raise web.HTTPConflict(text="The cabinet screen is already being viewed")
    response = web.StreamResponse(status=200, headers={
        "Content-Type": "multipart/x-mixed-replace; boundary=ffmpeg",
        "Cache-Control": "no-store, no-cache, must-revalidate",
        "X-Accel-Buffering": "no",
    })
    await response.prepare(request)
    async with SCREEN_LOCK:
        # Keep one HTTP stream alive while replacing ffmpeg whenever RetroPie
        # crosses menu -> runcommand -> emulator -> menu display modes.
        try:
            while request.transport is not None and not request.transport.is_closing():
                game_mode = bool(current_game())
                # The legacy /dev/fb0 exists on current Raspberry Pi OS but is a
                # zero-filled compatibility buffer, not the active KMS plane.
                # Release kmsgrab during runcommand/xinit's ownership handoff,
                # then reopen it against the new menu/game plane.
                if not game_mode and display_transition_active():
                    await asyncio.sleep(.12)
                    continue
                if game_mode:
                    # Godot homebrew owns an already-upright 768x1024 X11 desktop.
                    # KMS has no downloadable hardware frame while GLX owns it.
                    capture_args = (
                        "runuser", "-u", "pi", "--", "env", "DISPLAY=:0",
                        "ffmpeg", "-hide_banner", "-loglevel", "error",
                        "-f", "x11grab", "-video_size", "768x1024", "-framerate", "12", "-i", ":0",
                        "-vf", "scale=288:384:flags=fast_bilinear",
                    )
                else:
                    capture_args = (
                        "ffmpeg", "-hide_banner", "-loglevel", "error",
                        "-f", "kmsgrab", "-device", "/dev/dri/card1", "-framerate", "8", "-i", "-",
                        "-vf", "hwdownload,format=bgra,transpose=clock,scale=288:384:flags=fast_bilinear",
                    )
                process = await asyncio.create_subprocess_exec(
                    *capture_args,
                    "-q:v", "12", "-flush_packets", "1", "-f", "image2pipe", "-vcodec", "mjpeg", "pipe:1",
                    stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.DEVNULL,
                )
                try:
                    pending = b""
                    while request.transport is not None and not request.transport.is_closing():
                        chunk = await process.stdout.read(32768)
                        if not chunk: break
                        pending += chunk
                        while True:
                            start = pending.find(b"\xff\xd8")
                            end = pending.find(b"\xff\xd9", start + 2) if start >= 0 else -1
                            if start < 0 or end < 0:
                                if len(pending) > 2_000_000: pending = pending[-2:]
                                break
                            frame = pending[start:end + 2]
                            pending = pending[end + 2:]
                            header = (b"--ffmpeg\r\nContent-Type: image/jpeg\r\nContent-Length: "
                                      + str(len(frame)).encode() + b"\r\n\r\n")
                            await response.write(header + frame + b"\r\n")
                            # Restart capture as soon as a launch begins or the
                            # active renderer changes so its pixel format stays valid.
                            if bool(current_game()) != game_mode or (not game_mode and display_transition_active()): break
                        if bool(current_game()) != game_mode or (not game_mode and display_transition_active()): break
                finally:
                    if process.returncode is None:
                        process.terminate()
                        try: await asyncio.wait_for(process.wait(), 2)
                        except asyncio.TimeoutError: process.kill()
                await asyncio.sleep(.2)
        except (ConnectionResetError, BrokenPipeError, asyncio.CancelledError):
            pass
    return response


async def action(request):
    session=await require(request); data = await request.json(); name = data.get("action")
    commands = {
        "restart-menu": ("systemctl", "restart", "getty@tty1.service"),
        "reboot": ("systemctl", "reboot"), "shutdown": ("systemctl", "poweroff"),
        "music-next": ("/usr/local/bin/dreadwire-musicctl.py", "next"),
        "music-toggle": ("/usr/local/bin/dreadwire-musicctl.py", "toggle"),
        "music-up": ("/usr/local/bin/dreadwire-musicctl.py", "volumeup"),
        "music-down": ("/usr/local/bin/dreadwire-musicctl.py", "volumedown"),
        "master-up": ("runuser", "-u", "pi", "--", "pactl", "set-sink-volume", "@DEFAULT_SINK@", "+5%"),
        "master-down": ("runuser", "-u", "pi", "--", "pactl", "set-sink-volume", "@DEFAULT_SINK@", "-5%"),
    }
    if name == "mobile-player1":
        index = mobile_js_index()
        if index is None: raise web.HTTPConflict(text="Mobile gamepad is not ready")
        set_config_line("/opt/retropie/configs/all/retroarch.cfg", "input_player1_joypad_index", index)
        return web.json_response({"ok": True, "message": f"Mobile controller set as Player 1 (index {index})"})
    if name == "launch-enter":
        PAD.tap_key(e.KEY_ENTER)
        return web.json_response({"ok": True, "message": "Enter sent to RetroPie launcher"})
    if name == "launch-back":
        PAD.tap_key(e.KEY_ESC)
        return web.json_response({"ok": True, "message": "Back sent to RetroPie launcher"})
    if name in ("nav-up", "nav-down", "nav-left", "nav-right"):
        directions={"nav-up":(0,-1,e.KEY_UP),"nav-down":(0,1,e.KEY_DOWN),"nav-left":(-1,0,e.KEY_LEFT),"nav-right":(1,0,e.KEY_RIGHT)}
        _x,_y,key=directions[name]
        # A phone/browser can lose pointer-up and leave an analog axis held.
        # Neutralize the virtual pad before using the dedicated menu keyboard.
        PAD.release(); time.sleep(.04)
        # The frontend always accepts its dedicated keyboard profile, and a
        # single event avoids duplicate controller paths wrapping short lists.
        PAD.tap_key(key)
        return web.json_response({"ok":True})
    if session.get("role") != "admin": raise web.HTTPForbidden(text="Admin login required")
    if name == "restart-menu":
        # Homebrew games own a temporary X server. Starting EmulationStation
        # without closing it leaves two sessions competing for video and pads.
        run("pkill", "-TERM", "-x", "goldmaze.arm64")
        run("pkill", "-TERM", "-x", "void-run.arm64")
        run("pkill", "-TERM", "-x", "speedbike.arm64")
        run("pkill", "-TERM", "-x", "retroarch")
        await asyncio.sleep(1)
        run("pkill", "-TERM", "-x", "xinit")
        run("pkill", "-TERM", "-x", "Xorg")
        run("systemctl", "restart", "getty@tty1.service")
        run("/usr/local/bin/dreadwire-musicctl.py", "gameresume")
        log_event(session["name"], "restart-emulationstation")
        return web.json_response({"ok": True, "message": "Game session closed — EmulationStation restarted cleanly"})
    if name == "close-game":
        run("pkill", "-TERM", "-x", "retroarch")
        run("pkill", "-TERM", "-f", "/opt/dreadwire/void-run/void-run.arm64")
        run("pkill", "-TERM", "-f", "/opt/dreadwire/speedbike/speedbike.arm64")
        run("pkill", "-TERM", "-f", "/opt/dreadwire/goldmaze/goldmaze.arm64")
        await asyncio.sleep(2)
        run("pkill", "-KILL", "-x", "retroarch")
        run("pkill", "-TERM", "-x", "xinit")
        run("pkill", "-TERM", "-x", "Xorg")
        # A hard-stuck libretro core can leave runcommand's error console on tty1.
        # Restarting the login session always restores a clean EmulationStation menu.
        run("systemctl", "restart", "getty@tty1.service")
        run("/usr/local/bin/dreadwire-musicctl.py", "gameresume")
        log_event(session["name"], "force-close-game")
        return web.json_response({"ok":True,"message":"Game closed — returning to EmulationStation"})
    if name in ("music-toggle","music-next") and current_game():
        raise web.HTTPConflict(text="The menu jukebox stays paused during games. Use Master Volume for game audio.")
    if name in ("master-up","master-down"):
        run(*commands[name]); level=master_volume()
        return web.json_response({"ok":True,"message":f"Cabinet master volume: {level}%"})
    if name in ("music-up","music-down"):
        run(*commands[name])
        return web.json_response({"ok":True,"message":"Jukebox volume saved for the menu"})
    if name not in commands: raise web.HTTPBadRequest(text="Unknown action")
    subprocess.Popen(commands[name], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return web.json_response({"ok": True})


async def battery_update(request):
    await require(request); data = await request.json()
    try: percent = max(0.0, min(100.0, float(data["percent"])))
    except (KeyError, ValueError, TypeError): raise web.HTTPBadRequest(text="Percentage must be 0–100")
    now = time.time(); boot_id = text_file("/proc/sys/kernel/random/boot_id"); old = None
    try: old = json.loads(BATTERY_STATE.read_text())
    except (OSError, ValueError): pass
    rate = old.get("rate_per_hour") if old else None
    if old and old.get("boot_id") == boot_id:
        elapsed_hours = (now - float(old.get("updated", now))) / 3600
        drop = float(old.get("percent", percent)) - percent
        if elapsed_hours >= 5 / 60 and drop > 0:
            observed = drop / elapsed_hours
            if 0.2 <= observed <= 100:
                rate = observed if not rate else float(rate) * .65 + observed * .35
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    temporary = BATTERY_STATE.with_suffix(".tmp")
    temporary.write_text(json.dumps({"percent": percent, "updated": now,
                                     "rate_per_hour": rate, "boot_id": boot_id}, indent=2) + "\n")
    temporary.replace(BATTERY_STATE)
    return web.json_response({"ok": True, "learning": not bool(rate), "rate_per_hour": rate})


async def upload(request):
    await require(request,"admin"); category = request.match_info["category"]; cfg=settings()
    if not cfg["uploads_enabled"]: raise web.HTTPForbidden(text="Uploads are disabled in Admin settings")
    limit=(4*1024**3) if cfg["large_uploads"] else int(cfg["normal_limit_mb"])*1024**2
    if request.content_length and request.content_length > limit: raise web.HTTPRequestEntityTooLarge(max_size=limit,actual_size=request.content_length)
    if category == "roms":
        system = request.query.get("system", "")
        if not SAFE_SYSTEM.fullmatch(system): raise web.HTTPBadRequest(text="Choose a valid ROM system")
        destination = ROM_ROOT / system
    else:
        destination = UPLOADS.get(category)
    if destination is None: raise web.HTTPBadRequest(text="Invalid upload category")
    destination.mkdir(parents=True, exist_ok=True)
    reader = await request.multipart(); field = await reader.next()
    if not field or field.name != "file": raise web.HTTPBadRequest(text="Missing file")
    filename = Path(field.filename or "upload.bin").name
    target = destination / filename; temporary = target.with_suffix(target.suffix + ".uploading")
    size = 0
    with temporary.open("wb") as output:
        while chunk := await field.read_chunk(1024 * 1024):
            size += len(chunk)
            if size > limit:
                output.close(); temporary.unlink(missing_ok=True)
                raise web.HTTPRequestEntityTooLarge(max_size=limit,actual_size=size)
            output.write(chunk)
    temporary.replace(target); os.chown(target, 1000, 1000)
    return web.json_response({"ok": True, "file": filename, "bytes": size, "destination": str(destination)})


async def media_list(request):
    session=await require(request); cfg=settings()
    if session["role"]!="admin" and not cfg["media_enabled"]: raise web.HTTPForbidden(text="Media library is disabled")
    result={}
    for category,folder in MEDIA_CATEGORIES.items():
        result[category]=[{"name":p.name,"bytes":p.stat().st_size,"modified":p.stat().st_mtime,
                           "url":f"/api/media/{category}/{quote(p.name)}?token={quote(request_token(request))}"}
                          for p in sorted(folder.glob("*"),key=lambda x:x.stat().st_mtime,reverse=True)
                          if p.is_file() and p.suffix.lower() in MEDIA_EXTENSIONS[category]][:500]
    return web.json_response({"items":result,"settings":cfg,"admin":session["role"]=="admin"})


def media_target(category,filename):
    folder=MEDIA_CATEGORIES.get(category)
    if not folder: return None
    name=Path(filename).name; target=folder/name
    return target if name==filename and target.is_file() else None


async def media_file(request):
    session=await require(request); cfg=settings()
    if session["role"]!="admin" and not cfg["media_enabled"]: raise web.HTTPForbidden(text="Media library is disabled")
    target=media_target(request.match_info["category"],request.match_info["filename"])
    if not target: raise web.HTTPNotFound()
    return web.FileResponse(target,headers={"Content-Type":MIME_TYPES.get(target.suffix.lower(),"application/octet-stream")})


async def media_delete(request):
    s=await require(request,"admin"); target=media_target(request.match_info["category"],request.match_info["filename"])
    if not target: raise web.HTTPNotFound()
    name=target.name; target.unlink(); log_event(s["name"],"media-deleted",name)
    return web.json_response({"ok":True})


async def app_settings(request):
    s=await require(request); cfg=settings()
    if request.method=="GET": return web.json_response(cfg)
    if s["role"]!="admin": raise web.HTTPForbidden(text="Admin login required")
    data=await request.json()
    for key in ("media_enabled","uploads_enabled","large_uploads"):
        if key in data: cfg[key]=bool(data[key])
    if "party_launch_policy" in data:
        policy=str(data["party_launch_policy"])
        if policy not in {"admin_only","current_only","first_two","any_queued","everyone"}: raise web.HTTPBadRequest(text="Unknown game-launch policy")
        cfg["party_launch_policy"]=policy
    if "normal_limit_mb" in data: cfg["normal_limit_mb"]=max(5,min(1000,int(data["normal_limit_mb"])))
    write_settings(cfg); log_event(s["name"],"settings-changed",json.dumps(cfg))
    return web.json_response(cfg)


async def fan_settings(request):
    await require(request, "admin")
    config = {"profile":"balanced", "manual_speed":None, "manual_until":0}
    try: config.update(json.loads(FAN_CONFIG.read_text()))
    except (OSError, ValueError, TypeError): pass
    if request.method == "GET":
        config["state"] = json.loads(text_file(FAN_STATE, "{}"))
        return web.json_response(config)
    data = await request.json()
    profile = str(data.get("profile", config["profile"]))
    if profile not in ("quiet", "balanced", "cool"):
        raise web.HTTPBadRequest(text="Unknown fan profile")
    mode = data.get("mode", "auto")
    config["profile"] = profile
    if mode == "manual":
        speed = int(data.get("speed", 100))
        if speed not in (0, 25, 50, 75, 100):
            raise web.HTTPBadRequest(text="Fan speed must be 0, 25, 50, 75, or 100")
        config["manual_speed"] = speed
        config["manual_until"] = time.time() + max(1, min(30, int(data.get("minutes", 5)))) * 60
    else:
        config["manual_speed"] = None
        config["manual_until"] = 0
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    temporary=FAN_CONFIG.with_suffix(".tmp"); temporary.write_text(json.dumps(config,indent=2)+"\n"); temporary.replace(FAN_CONFIG)
    log_event("admin", "fan-settings", json.dumps(config))
    return web.json_response({"ok":True, **config})


async def wifi_networks(request):
    await require(request, "admin")
    result = await asyncio.to_thread(nmcli, "-t", "--escape", "yes", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "device", "wifi", "list", "--rescan", "yes")
    if result.returncode != 0:
        raise web.HTTPServiceUnavailable(text=result.stderr.strip() or "Wi-Fi scan failed")
    networks={}
    for line in result.stdout.splitlines():
        fields=split_nmcli(line)
        if len(fields) < 4 or not fields[1]: continue
        active=fields[0].strip() == "*"; ssid=fields[1]
        try: signal=int(fields[2])
        except ValueError: signal=0
        item={"ssid":ssid,"signal":signal,"security":fields[3] or "Open","active":active}
        if ssid not in networks or signal > networks[ssid]["signal"]: networks[ssid]=item
    active=await asyncio.to_thread(nmcli, "-t", "--escape", "yes", "-f", "NAME,TYPE,DEVICE", "connection", "show", "--active")
    return web.json_response({"networks":sorted(networks.values(),key=lambda n:(not n["active"],-n["signal"],n["ssid"].lower())),"connections":[split_nmcli(x)[0] for x in active.stdout.splitlines() if ":802-11-wireless:" in x]})


async def wifi_connect(request):
    session=await require(request, "admin"); data=await request.json()
    ssid=str(data.get("ssid", "")).strip(); password=str(data.get("password", ""))
    if not ssid or len(ssid) > 128: raise web.HTTPBadRequest(text="Choose a valid Wi-Fi network")
    command=["device","wifi","connect",ssid]
    if password: command += ["password",password]
    result=await asyncio.to_thread(nmcli,*command,timeout=45)
    if result.returncode != 0: raise web.HTTPBadRequest(text=result.stderr.strip() or result.stdout.strip() or "Could not connect")
    log_event(session["name"],"wifi-connect",ssid)
    return web.json_response({"ok":True,"message":f"Connected to {ssid}. This network will be remembered."})


async def wifi_forget(request):
    session=await require(request,"admin"); data=await request.json(); name=str(data.get("name","")).strip()
    if not name: raise web.HTTPBadRequest(text="Choose a saved network")
    result=await asyncio.to_thread(nmcli,"connection","delete",name)
    if result.returncode != 0: raise web.HTTPBadRequest(text=result.stderr.strip() or "Could not forget network")
    log_event(session["name"],"wifi-forget",name)
    return web.json_response({"ok":True,"message":f"Forgot {name}"})


def update_configuration():
    config={"repository":"","channel":"stable"}
    try: config.update(json.loads(UPDATE_CONFIG.read_text()))
    except (OSError,ValueError,TypeError): pass
    return config


async def update_status(request):
    await require(request)
    config=update_configuration(); repository=str(config.get("repository","")).strip().strip("/")
    response={"current":PACKAGE_VERSION,"configured":bool(repository),"repository":repository,"channel":config.get("channel","stable"),"available":False,"latest":PACKAGE_VERSION,"notes":[]}
    if not repository: return web.json_response(response)
    url=f"https://api.github.com/repos/{repository}/releases/latest"
    def fetch_release():
        req=urllib.request.Request(url,headers={"Accept":"application/vnd.github+json","User-Agent":"Dreadwire-Arcade-Updater/1.0"})
        with urllib.request.urlopen(req,timeout=8) as source: return json.load(source)
    try:
        release=await asyncio.to_thread(fetch_release); latest=str(release.get("tag_name",PACKAGE_VERSION)).lstrip("v")
        body=str(release.get("body","")).strip(); response.update({"latest":latest,"available":latest != PACKAGE_VERSION,"name":release.get("name") or latest,"notes":[x.strip(" -*") for x in body.splitlines() if x.strip()][:8],"published":release.get("published_at")})
    except Exception as exc: response["error"]="Update server unavailable"
    return web.json_response(response)


async def update_install(request):
    session=await require(request,"admin"); config=update_configuration()
    if not config.get("repository"): raise web.HTTPConflict(text="GitHub release source is not configured yet")
    process=subprocess.Popen(["systemctl","start","dreadwire-update.service"],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
    log_event(session["name"],"update-install",str(config.get("repository")))
    return web.json_response({"ok":True,"message":"Update started. The cabinet will restart when installation finishes."})


def game_catalog(query=""):
    """Return EmulationStation metadata without trusting ROM paths from clients."""
    query=query.casefold().strip(); matches=[]
    if len(query) < 2: return matches
    for system_dir in sorted(ROM_ROOT.iterdir()) if ROM_ROOT.exists() else []:
        if not system_dir.is_dir(): continue
        candidates=(system_dir / "gamelist.xml", Path("/opt/retropie/configs/all/emulationstation/gamelists") / system_dir.name / "gamelist.xml")
        gamelist=next((p for p in candidates if p.is_file()),None)
        if not gamelist: continue
        try:
            import xml.etree.ElementTree as ET
            root=ET.parse(gamelist).getroot()
            for game in root.findall("game"):
                title=(game.findtext("name") or "").strip(); path=(game.findtext("path") or "").strip()
                if query not in title.casefold(): continue
                image=(game.findtext("image") or "").strip(); desc=(game.findtext("desc") or "").strip()
                matches.append({"title":title,"system":system_dir.name,"path":path,"image":image,"description":desc[:240]})
                if len(matches) >= 50: return matches
        except (OSError, ValueError, ET.ParseError): continue
    return matches


async def search_games(request):
    await require(request)
    return web.json_response({"games":await asyncio.to_thread(game_catalog,request.query.get("q",""))})


def game_control_allowed(session):
    user_key=str(session.get("user_id") or session["name"])
    if session.get("role")=="admin": return True
    policy=settings().get("party_launch_policy","any_queued")
    if policy=="everyone": return True
    if policy=="admin_only": return False
    with db() as conn:
        rows=conn.execute("SELECT user_key,state FROM party_queue ORDER BY CASE state WHEN 'active' THEN 0 WHEN 'invited' THEN 1 ELSE 2 END,joined").fetchall()
    if policy=="current_only": return bool(rows and rows[0]["state"]=="active" and rows[0]["user_key"]==user_key)
    if policy=="first_two": return user_key in [row["user_key"] for row in rows[:2]]
    return user_key in [row["user_key"] for row in rows]


def resolve_game(system,relative):
    if not SAFE_SYSTEM.fullmatch(system): raise web.HTTPBadRequest(text="Invalid system")
    system_root=(ROM_ROOT/system).resolve()
    rom=(system_root/relative.removeprefix("./")).resolve()
    if system_root not in rom.parents or not rom.is_file(): raise web.HTTPNotFound(text="ROM file not found")
    return rom


async def select_game(request):
    session=await require(request)
    if not game_control_allowed(session): raise web.HTTPForbidden(text="You are not currently allowed to select games")
    data=await request.json()
    if data.get("action")=="clear":
        GAME_SELECTION.clear(); await broadcast_party(); return web.json_response(party_state())
    system=str(data.get("system","")); relative=str(data.get("path","")); rom=resolve_game(system,relative)
    GAME_SELECTION.clear(); GAME_SELECTION.update({"id":secrets.token_urlsafe(8),"title":str(data.get("title") or rom.stem)[:120],
        "system":system,"path":str(rom),"selected_by":session["name"],"selected_at":time.time(),"status":"selected"})
    log_event(session["name"],"game-selected",f"{system}/{rom.name}",session.get("user_id"))
    await broadcast_party()
    return web.json_response({"ok":True,"message":f'{GAME_SELECTION["title"]} selected',"selection":GAME_SELECTION["id"]})


async def launch_sequence(selection):
    system=selection["system"]; rom=Path(selection["path"])
    selection["status"]="closing-current-game"; await broadcast_party()
    for name in ("retroarch","flycast","reicast","goldmaze.arm64","void-run.arm64","speedbike.arm64"):
        run("pkill","-TERM","-x",name)
    deadline=time.monotonic()+8
    while time.monotonic()<deadline:
        running=any(run("pgrep","-x",name).returncode==0 for name in ("retroarch","flycast","reicast","goldmaze.arm64","void-run.arm64","speedbike.arm64"))
        if not running: break
        await asyncio.sleep(.5)
    for name in ("retroarch","flycast","reicast","goldmaze.arm64","void-run.arm64","speedbike.arm64"):
        run("pkill","-KILL","-x",name)
    deadline=time.monotonic()+6
    while time.monotonic()<deadline and run("pgrep","-f","/opt/retropie/supplementary/runcommand/runcommand.sh").returncode==0:
        await asyncio.sleep(.5)
    await asyncio.sleep(1)
    selection["status"]="launching"; await broadcast_party()
    run("/usr/local/bin/dreadwire-musicctl.py","gamepause")
    run("systemctl","stop","getty@tty1.service")
    await asyncio.sleep(1)
    process=subprocess.Popen(["openvt","-c","1","-f","-s","-w","--","runuser","-u","pi","--",
                              "/opt/retropie/supplementary/runcommand/runcommand.sh","0","_SYS_",system,str(rom)],
                             stdin=subprocess.DEVNULL,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,start_new_session=True)
    await asyncio.sleep(5)
    if process.poll() is not None:
        selection["status"]="launch-failed"; await broadcast_party()
        run("systemctl","restart","getty@tty1.service"); run("/usr/local/bin/dreadwire-musicctl.py","gameresume")
        return
    GAME_SELECTION.clear(); await broadcast_party()
    await asyncio.to_thread(process.wait)
    run("systemctl","restart","getty@tty1.service")
    run("/usr/local/bin/dreadwire-musicctl.py","gameresume")


async def launch_game(request):
    session=await require(request)
    if not game_control_allowed(session): raise web.HTTPForbidden(text="You are not currently allowed to start games")
    data=await request.json()
    if not GAME_SELECTION or str(data.get("selection_id",""))!=GAME_SELECTION.get("id"): raise web.HTTPConflict(text="That game selection expired")
    if GAME_SELECTION.get("status")!="selected": raise web.HTTPConflict(text="A game is already launching")
    selection=GAME_SELECTION.copy(); GAME_SELECTION.update(selection)
    system=selection["system"]; rom=Path(selection["path"])
    asyncio.create_task(launch_sequence(GAME_SELECTION))
    log_event(session["name"],"remote-game-launch",f"{system}/{rom.name}",session.get("user_id"))
    return web.json_response({"ok":True,"message":f'Preparing {selection["title"]}'})


def controller_telemetry():
    batteries=[]
    for capacity in Path("/sys/class/power_supply").glob("*/capacity"):
        try:
            base=capacity.parent; scope=text_file(base / "scope", "").strip().lower()
            kind=text_file(base / "type", "").strip().lower()
            if scope == "system" or kind in {"mains","usb","usb_c"}: continue
            batteries.append({"name":text_file(base / "model_name", "").strip() or text_file(base / "manufacturer", "").strip() or base.name,
                              "battery":int(capacity.read_text().strip()),"charging":text_file(base / "status", "").strip()})
        except (OSError,ValueError): continue
    devices=[]
    for path in list_devices():
        try:
            device=InputDevice(path); caps=device.capabilities()
            if e.EV_ABS not in caps and e.EV_KEY not in caps: continue
            keys=set(caps.get(e.EV_KEY,[]))
            if not ({e.BTN_GAMEPAD,e.BTN_JOYSTICK,e.BTN_SOUTH,e.BTN_START} & keys): continue
            battery=next((b for b in batteries if b["name"].casefold() in device.name.casefold() or device.name.casefold() in b["name"].casefold()),None)
            devices.append({"name":device.name,"path":path,"connection":"Bluetooth" if "bluetooth" in (device.phys or "").casefold() else "USB / wired",
                            "battery":battery["battery"] if battery else None,"charging":battery["charging"] if battery else "",
                            "virtual":device.name.startswith("Dreadwire ")})
        except OSError: continue
    return devices


async def telemetry_controllers(request):
    await require(request)
    return web.json_response({"controllers":await asyncio.to_thread(controller_telemetry)})


async def scores(request):
    session=await require(request)
    if request.method == "POST":
        data=await request.json(); game=str(data.get("game","")).strip()[:120]
        try: score=int(data.get("score"))
        except (TypeError,ValueError): raise web.HTTPBadRequest(text="Score must be a number")
        if not game or score < 0 or score > 2_147_483_647: raise web.HTTPBadRequest(text="Invalid game or score")
        with db() as conn: conn.execute("INSERT INTO high_scores(user_id,username,game_title,score,created) VALUES(?,?,?,?,?)",
                                       (session.get("user_id"),session["name"],game,score,time.time()))
        log_event(session["name"],"score-submitted",f"{game}: {score}",session.get("user_id"))
    game=str(request.query.get("game","")).strip()[:120]
    with db() as conn:
        if game: rows=conn.execute("SELECT username,game_title,score,created FROM high_scores WHERE game_title=? ORDER BY score DESC,created ASC LIMIT 20",(game,))
        else: rows=conn.execute("SELECT username,game_title,score,created FROM high_scores ORDER BY created DESC LIMIT 30")
        result=[dict(row) for row in rows]
    return web.json_response({"scores":result,"game":game})


def party_state():
    now=time.time()
    try: mode=json.loads(ARCADE_MODE_STATE.read_text()).get("mode","classic")
    except (OSError,ValueError,TypeError): mode="classic"
    with db() as conn:
        expired=conn.execute("SELECT name FROM party_queue WHERE state='invited' AND invited_until<?",(now,)).fetchall()
        conn.execute("DELETE FROM party_queue WHERE state='invited' AND invited_until<?",(now,))
        active=conn.execute("SELECT id FROM party_queue WHERE state IN ('active','invited') ORDER BY joined LIMIT 1").fetchone()
        if not active:
            waiting=conn.execute("SELECT id FROM party_queue WHERE state='waiting' ORDER BY joined LIMIT 1").fetchone()
            if waiting: conn.execute("UPDATE party_queue SET state='invited',invited_until=? WHERE id=?",(now+60,waiting["id"]))
        queue=[dict(row) for row in conn.execute("SELECT id,name,state,joined,invited_until,accepted FROM party_queue ORDER BY CASE state WHEN 'active' THEN 0 WHEN 'invited' THEN 1 ELSE 2 END,joined LIMIT 50")]
        chat=[dict(row) for row in conn.execute("SELECT name AS sender,message,created AS at FROM party_chat ORDER BY id DESC LIMIT 50")][::-1]
    selected={key:value for key,value in GAME_SELECTION.items() if key!="path"} if GAME_SELECTION else None
    return {"mode":mode,"launch_policy":settings().get("party_launch_policy","any_queued"),"selected_game":selected,
            "count":len(queue),"queue":queue,"current":next((x for x in queue if x["state"]=="active"),None),
            "invited":next((x for x in queue if x["state"]=="invited"),None),"chat":chat,
            "expired":[row["name"] for row in expired],"server_time":now}


async def broadcast_party():
    payload=json.dumps({"type":"state",**party_state()})
    stale=[]
    for ws in PARTY_CLIENTS:
        try: await ws.send_str(payload)
        except (ConnectionError,RuntimeError): stale.append(ws)
    for ws in stale: PARTY_CLIENTS.discard(ws)


async def party_status(request):
    await require(request)
    return web.json_response(party_state())


async def party_display(_):
    state=party_state()
    return web.json_response({"mode":state["mode"],"count":state["count"],
                              "current":state["current"]["name"] if state["current"] else None,
                              "waiting":[item["name"] for item in state["queue"] if item["state"]=="waiting"][:8]})


async def party_queue(request):
    session=await require(request); data=await request.json(); action=str(data.get("action","join"))
    name=session["name"][:40]; key=str(session.get("user_id") or name)
    with db() as conn:
        if action == "join":
            conn.execute("INSERT INTO party_queue(user_key,name,state,joined,last_seen) VALUES(?,?,'waiting',?,?) ON CONFLICT(user_key) DO UPDATE SET name=excluded.name,state='waiting',joined=excluded.joined,last_seen=excluded.last_seen,invited_until=NULL,accepted=NULL",(key,name,time.time(),time.time()))
        elif action == "leave": conn.execute("DELETE FROM party_queue WHERE user_key=?",(key,))
        elif action == "accept":
            row=conn.execute("SELECT state,invited_until FROM party_queue WHERE user_key=?",(key,)).fetchone()
            if not row or row["state"]!="invited" or (row["invited_until"] or 0)<time.time(): raise web.HTTPConflict(text="Your invitation expired")
            conn.execute("UPDATE party_queue SET state='active',accepted=?,invited_until=NULL WHERE user_key=?",(time.time(),key))
        elif action in {"advance","clear","remove","extend"}:
            active=conn.execute("SELECT user_key FROM party_queue WHERE state='active' LIMIT 1").fetchone()
            if session.get("role")!="admin" and (not active or active["user_key"]!=key): raise web.HTTPForbidden(text="Current player or admin required")
            if action == "advance": conn.execute("DELETE FROM party_queue WHERE state IN ('active','invited')")
            elif action == "clear": conn.execute("DELETE FROM party_queue")
            elif action == "remove": conn.execute("DELETE FROM party_queue WHERE id=?",(int(data.get("id",0)),))
            elif action == "extend":
                minutes=max(1,min(3,int(data.get("minutes",1))))
                conn.execute("UPDATE party_queue SET invited_until=COALESCE(invited_until,?)+? WHERE state='invited'",(time.time(),minutes*60))
        else: raise web.HTTPBadRequest(text="Unknown queue action")
    log_event(name,f"party-{action}",user_id=session.get("user_id")); await broadcast_party()
    return web.json_response(party_state())


async def party_socket(request):
    session=await require(request); ws=web.WebSocketResponse(heartbeat=15,max_msg_size=4096); await ws.prepare(request)
    PARTY_CLIENTS.add(ws); PARTY_CONNECTIONS[ws]=str(session.get("user_id") or session["name"])
    with db() as conn: conn.execute("UPDATE party_queue SET last_seen=? WHERE user_key=?",(time.time(),PARTY_CONNECTIONS[ws]))
    with db() as conn: conn.execute("INSERT INTO party_chat(user_key,name,message,created) VALUES(?,?,?,?)",
                                    (str(session.get("user_id") or session["name"]), "SYSTEM", f'{session["name"]} joined the party chat', time.time()))
    await broadcast_party()
    try:
        async for msg in ws:
            if msg.type != WSMsgType.TEXT: continue
            try: data=json.loads(msg.data)
            except ValueError: continue
            if data.get("type") == "chat":
                body=str(data.get("message","")).strip()[:240]
                if body:
                    with db() as conn:
                        conn.execute("INSERT INTO party_chat(user_key,name,message,created) VALUES(?,?,?,?)",(str(session.get("user_id") or session["name"]),session["name"][:40],body,time.time()))
                        conn.execute("DELETE FROM party_chat WHERE id NOT IN (SELECT id FROM party_chat ORDER BY id DESC LIMIT 500)")
                    await broadcast_party()
    finally:
        PARTY_CLIENTS.discard(ws); PARTY_CONNECTIONS.pop(ws,None)
        with db() as conn: conn.execute("INSERT INTO party_chat(user_key,name,message,created) VALUES(?,?,?,?)",
                                        (str(session.get("user_id") or session["name"]), "SYSTEM", f'{session["name"]} left the party chat', time.time()))
        await broadcast_party()
    return ws


async def party_clock_context(app):
    async def clock():
        while True:
            now=time.time(); connected=set(PARTY_CONNECTIONS.values())
            with db() as conn:
                for key in connected: conn.execute("UPDATE party_queue SET last_seen=? WHERE user_key=?",(now,key))
                conn.execute("DELETE FROM party_queue WHERE state!='active' AND COALESCE(last_seen,joined)<?",(now-120,))
                conn.execute("DELETE FROM party_queue WHERE state='active' AND COALESCE(last_seen,joined)<?",(now-900,))
            await broadcast_party()
            await asyncio.sleep(1)
    task=asyncio.create_task(clock())
    yield
    task.cancel()
    try: await task
    except asyncio.CancelledError: pass


async def party_overlay(_): return web.FileResponse(WEB / "overlay.html")


async def party_qr(_):
    path=Path("/home/pi/RetroPie/roms/companion/media/arcade-remote-qr.png")
    if not path.is_file(): raise web.HTTPNotFound(text="QR code is being prepared")
    return web.FileResponse(path)


async def controller(request):
    await require(request)
    try: player=max(1,min(4,int(request.query.get("player","1"))))
    except ValueError: player=1
    pad=PADS[player-1]
    ws = web.WebSocketResponse(heartbeat=10, max_msg_size=65536); await ws.prepare(request)
    WS_CLIENTS.add(ws)
    await ws.send_json({"ready": True, "index": mobile_js_index(player), "player":player})
    try:
        async for msg in ws:
            if msg.type == WSMsgType.TEXT:
                try: pad.emit(json.loads(msg.data))
                except (ValueError, TypeError, KeyError): pass
    finally: WS_CLIENTS.discard(ws); pad.release()
    return ws


app = web.Application(client_max_size=4 * 1024**3)
app.cleanup_ctx.append(physical_controller_context)
app.cleanup_ctx.append(party_clock_context)
app.add_routes([web.get("/", index), web.post("/api/login", login), web.post("/api/guest", guest), web.post("/api/logout", logout),
                web.post("/api/register", register), web.get("/api/me", me), web.get("/api/status", status),
                web.get("/api/layout/{preset}", profile_layout), web.put("/api/layout/{preset}", profile_layout),
                web.get("/api/admin/users", admin_users), web.post("/api/admin/reset-password", admin_reset),
                web.get("/api/settings", app_settings), web.put("/api/settings", app_settings),
                web.get("/api/fan", fan_settings), web.put("/api/fan", fan_settings),
                web.get("/api/wifi", wifi_networks), web.post("/api/wifi/connect", wifi_connect),
                web.post("/api/wifi/forget", wifi_forget),
                web.get("/api/update", update_status), web.post("/api/update/install", update_install),
                web.get("/api/games/search", search_games), web.get("/api/telemetry/controllers", telemetry_controllers),
                web.post("/api/games/select", select_game), web.post("/api/games/launch", launch_game),
                web.get("/api/scores", scores), web.post("/api/scores", scores),
                web.get("/api/party", party_status), web.get("/api/party/display", party_display), web.post("/api/party/queue", party_queue),
                web.get("/ws/party", party_socket), web.get("/overlay-qr", party_overlay), web.get("/api/party/qr.png", party_qr),
                web.get("/api/audio", audio_control), web.put("/api/audio", audio_control),
                web.get("/api/screen.jpg", screen_frame), web.get("/api/screen.mjpeg", screen_stream),
                web.get("/api/media", media_list), web.get("/api/media/{category}/{filename}", media_file),
                web.delete("/api/media/{category}/{filename}", media_delete),
                web.post("/api/action", action), web.post("/api/upload/{category}", upload),
                web.post("/api/battery", battery_update),
                web.get("/ws/controller", controller), web.static("/static", WEB)])
web.run_app(app, host="0.0.0.0", port=8765, access_log=None)
