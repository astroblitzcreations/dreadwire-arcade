let token = localStorage.dwToken || "",
  session = null,
  ws = null,
  loggingOut = false,
  editing = false,
  selected = null,
  remoteGameState = null,
  remoteRestartTimer = null;
const $ = (s) => document.querySelector(s),
  $$ = (s) => document.querySelectorAll(s);
const audioTab = document.createElement("button");
audioTab.dataset.tab = "audio";
audioTab.textContent = "AUDIO";
document
  .querySelector("nav")
  .insertBefore(audioTab, document.querySelector('[data-tab="admin"]'));
const audioSection = document.createElement("section");
audioSection.id = "audio";
audioSection.className = "tab";
audioSection.innerHTML =
  '<div class="card" id="audioMixer"><h2>Arcade Audio Mixer</h2><p class="hint">Master affects everything. Background music and menu sounds can be adjusted or muted separately.</p><label>MASTER <b id="masterLevel">—</b><input id="masterSlider" type="range" min="0" max="125" step="5"><button id="masterMute">MUTE</button></label><label>BACKGROUND MUSIC <b id="musicLevel">—</b><input id="musicSlider" type="range" min="0" max="125" step="5"><button id="musicMute">MUTE</button></label><label>MENU SOUNDS <b id="menuLevel">—</b><input id="menuSlider" type="range" min="0" max="100" step="5"><button id="menuMute">MUTE</button></label></div>';
document
  .querySelector("main")
  .insertBefore(audioSection, document.querySelector("#admin"));
function toast(m) {
  const t = $("#toast");
  t.textContent = m;
  t.classList.add("show");
  setTimeout(() => t.classList.remove("show"), 2800);
}
function esc(v) {
  return String(v ?? "").replace(
    /[&<>"']/g,
    (c) =>
      ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[
        c
      ],
  );
}
async function api(path, opts = {}) {
  opts.headers = { ...(opts.headers || {}), Authorization: `Bearer ${token}` };
  const r = await fetch(path, opts);
  if (!r.ok) throw new Error(await r.text());
  return r.json();
}
async function acceptAuth(r) {
  if (!r.ok) throw new Error(await r.text());
  const d = await r.json();
  token = d.token;
  localStorage.dwToken = token;
  await enter();
}
async function enter() {
  try {
    session = await api("/api/me");
    $("#login").hidden = true;
    $("#app").hidden = false;
    $$(
      "[data-tab=admin],[data-tab=media],[data-tab=audio],[data-tab=wifi],.adminOnly",
    ).forEach((x) => (x.hidden = session.role !== "admin"));
    connect();
    await loadRemoteLayout(localStorage.dwPadTheme || "arcade");
    refresh();
    checkForUpdates();
  } catch (e) {
    localStorage.removeItem("dwToken");
    token = "";
    $("#login").hidden = false;
  }
}
$("#guestBtn").onclick = async () => {
  try {
    await acceptAuth(await fetch("/api/guest", { method: "POST" }));
  } catch (e) {
    $("#loginMsg").textContent = e.message;
  }
};
$("#registerBtn").onclick = async () => {
  try {
    await acceptAuth(
      await fetch("/api/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          username: $("#newUser").value,
          email: $("#newEmail").value,
          password: $("#newPass").value,
        }),
      }),
    );
  } catch (e) {
    $("#loginMsg").textContent = e.message;
  }
};
$("#loginBtn").onclick = async () => {
  try {
    await acceptAuth(
      await fetch("/api/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          username: $("#user").value,
          password: $("#pass").value,
        }),
      }),
    );
  } catch (e) {
    $("#loginMsg").textContent = e.message;
  }
};
function syncPadMode() {
  const active =
    $("#pad").classList.contains("active") ||
    $("#remote").classList.contains("active");
  document.documentElement.classList.toggle("pad-active", active);
  document.body.classList.toggle("pad-active", active);
}
$$("nav button").forEach(
  (b) =>
    (b.onclick = () => {
      $$("nav button,.tab").forEach((x) => x.classList.remove("active"));
      b.classList.add("active");
      $("#" + b.dataset.tab).classList.add("active");
      syncPadMode();
      setControllerHost(b.dataset.tab);
      if (b.dataset.tab === "remote") startRemoteStream();
      else stopRemoteStream();
      if (b.dataset.tab === "admin" && session?.role === "admin") {
        loadUsers();
        loadSettings();
        loadFan();
      }
      if (b.dataset.tab === "audio") loadAudio();
      if (b.dataset.tab === "library") loadLibrary();
      if (b.dataset.tab === "party") loadParty();
      if (b.dataset.tab === "wifi") loadWifi();
    }),
);
function connect() {
  if (loggingOut || !token) return;
  if (ws) {
    ws.onclose = null;
    ws.close();
  }
  const player = Math.max(1, Math.min(4, +(localStorage.dwPlayerSlot || 1)));
  ws = new WebSocket(
    `${location.protocol === "https:" ? "wss" : "ws"}://${location.host}/ws/controller?token=${encodeURIComponent(token)}&player=${player}`,
  );
  ws.onopen = () => {
    $("#connection").textContent =
      `LINKED • P${player} • ${session?.name || "PLAYER"}`;
    $("#connection").classList.add("online");
  };
  ws.onclose = () => {
    if (loggingOut) return;
    $("#connection").textContent = "RECONNECTING";
    $("#connection").classList.remove("online");
    setTimeout(connect, 1200);
  };
}
$("#logoutBtn").onclick = async () => {
  loggingOut = true;
  $("#logoutBtn").disabled = true;
  $("#logoutBtn").textContent = "LOGGING OUT…";
  try {
    await api("/api/logout", { method: "POST" });
  } catch (_) {
    // Local logout still succeeds if the cabinet briefly drops offline.
  }
  ws?.close();
  partySocket?.close();
  localStorage.removeItem("dwToken");
  token = "";
  location.reload();
};
function send(o) {
  if (ws?.readyState === 1) ws.send(JSON.stringify(o));
}
$$("[data-button]").forEach((b) => {
  const code = b.dataset.button;
  let downAt = 0;
  const down = (e) => {
    if (editing) return;
    e.preventDefault();
    downAt = performance.now();
    b.setPointerCapture?.(e.pointerId);
    b.classList.add("active");
    // EmulationStation can miss the virtual joypad's very short browser tap.
    // Menu confirm/back use the dedicated keyboard action endpoint instead;
    // games still receive the normal held gamepad button below.
    if (!lastStatus?.game && ["a", "start", "b"].includes(code)) {
      navigator.vibrate?.(12);
      return;
    }
    send({ type: "button", code, pressed: true });
    navigator.vibrate?.(12);
  };
  const up = (e) => {
    if (editing) return;
    e.preventDefault();
    b.classList.remove("active");
    if (!lastStatus?.game && ["a", "start", "b"].includes(code)) {
      action(code === "b" ? "launch-back" : "launch-enter");
      return;
    }
    const release = () => send({ type: "button", code, pressed: false }),
      wait = Math.max(0, 80 - (performance.now() - downAt));
    setTimeout(release, wait);
  };
  b.onpointerdown = down;
  b.onpointerup = up;
  b.onpointercancel = up;
  b.oncontextmenu = (e) => e.preventDefault();
});
const stick = $("#stick"),
  knob = stick.firstElementChild;
function stickMove(e) {
  if (editing) return;
  const r = stick.getBoundingClientRect(),
    cx = r.left + r.width / 2,
    cy = r.top + r.height / 2,
    rad = r.width * 0.31;
  let x = (e.clientX - cx) / rad,
    y = (e.clientY - cy) / rad,
    m = Math.hypot(x, y);
  if (m > 1) {
    x /= m;
    y /= m;
  }
  knob.style.transform = `translate(${x * rad}px,${y * rad}px)`;
  send({ type: "axis", x, y });
}
stick.onpointerdown = (e) => {
  if (editing) return;
  stick.setPointerCapture(e.pointerId);
  stickMove(e);
};
stick.onpointermove = (e) => {
  if (e.buttons) stickMove(e);
};
function stickUp() {
  if (editing) return;
  knob.style.transform = "";
  send({ type: "axis", x: 0, y: 0 });
}
stick.onpointerup = stickUp;
stick.onpointercancel = stickUp;
const dstate = { up: false, down: false, left: false, right: false };
function releaseRemoteControls() {
  knob.style.transform = "";
  send({ type: "axis", x: 0, y: 0 });
  Object.keys(dstate).forEach((key) => (dstate[key] = false));
  send({ type: "dpad", x: 0, y: 0 });
  $$('[data-button]').forEach((button) => {
    button.classList.remove("active");
    send({ type: "button", code: button.dataset.button, pressed: false });
  });
}
addEventListener("pointerup", releaseRemoteControls);
addEventListener("pointercancel", releaseRemoteControls);
addEventListener("blur", releaseRemoteControls);
addEventListener("pagehide", releaseRemoteControls);
document.addEventListener("visibilitychange", () => {
  if (document.hidden) releaseRemoteControls();
});
function dsend() {
  send({
    type: "dpad",
    x: (dstate.right ? 1 : 0) - (dstate.left ? 1 : 0),
    y: (dstate.down ? 1 : 0) - (dstate.up ? 1 : 0),
  });
}
$$("[data-dir]").forEach((b) => {
  const dir = b.dataset.dir;
  b.onpointerdown = (e) => {
    if (editing) return;
    e.preventDefault();
    b.setPointerCapture?.(e.pointerId);
    b.classList.add("active");
    if (!lastStatus?.game) {
      action("nav-" + dir);
      return;
    }
    dstate[dir] = true;
    dsend();
  };
  const up = (e) => {
    if (editing) return;
    e.preventDefault();
    b.classList.remove("active");
    if (!lastStatus?.game) return;
    dstate[dir] = false;
    dsend();
  };
  b.onpointerup = up;
  b.onpointercancel = up;
});
const stage = $("#controller"),
  themeSelect = $("#padTheme"),
  stageHome = stage.parentNode,
  stageNext = stage.nextSibling;
const playerSlot = document.createElement("select");
playerSlot.id = "playerSlot";
playerSlot.title = "Choose which in-game player this phone controls";
playerSlot.innerHTML = [1, 2, 3, 4]
  .map((n) => `<option value="${n}">PLAYER ${n}</option>`)
  .join("");
playerSlot.value = localStorage.dwPlayerSlot || "1";
themeSelect.parentNode.insertBefore(playerSlot, themeSelect);
playerSlot.onchange = () => {
  localStorage.dwPlayerSlot = playerSlot.value;
  connect();
  toast(`This phone is now Player ${playerSlot.value}`);
};
$("#player1").hidden = true;
const fanCard = document.createElement("div");
fanCard.className = "card";
fanCard.innerHTML =
  '<h2>Argon Fan HAT</h2><p id="fanNow">Checking fan…</p><label>Cooling profile<select id="fanProfile"><option value="quiet">Quiet</option><option value="balanced">Balanced</option><option value="cool">Cool / maximum protection</option></select></label><div class="actionrow"><button id="fanAuto">USE AUTOMATIC</button><button id="fan50">TEST 50%</button><button id="fan100">TEST 100%</button></div><p class="hint">Manual tests last five minutes, then automatically return to temperature control.</p>';
$("#admin .grid:last-of-type").appendChild(fanCard);
function setControllerHost(tab) {
  if (tab === "remote") $("#remoteControllerMount").appendChild(stage);
  else if (stage.parentNode !== stageHome)
    stageHome.insertBefore(stage, stageNext);
}
function stopRemoteStream() {
  clearTimeout(remoteRestartTimer);
  remoteRestartTimer = null;
  $("#screenFeed").removeAttribute("src");
  $("#streamState").textContent = "PAUSED";
}
function scheduleRemoteResync(delay = 400) {
  clearTimeout(remoteRestartTimer);
  remoteRestartTimer = setTimeout(() => {
    if ($("#remote").classList.contains("active")) startRemoteStream();
  }, delay);
}
function startRemoteStream() {
  stopRemoteStream();
  const feed = $("#screenFeed");
  $("#streamState").textContent = "CONNECTING";
  remoteRestartTimer = setTimeout(() => {
    feed.onload = () => ($("#streamState").textContent = "LIVE");
    feed.onerror = () => {
      $("#streamState").textContent = "RECONNECTING";
      scheduleRemoteResync(900);
    };
    feed.src = `/api/screen.mjpeg?token=${encodeURIComponent(token)}&ts=${Date.now()}`;
  }, 350);
}
const remote = $("#remote"),
  fullscreenButton = $("#remoteFullscreen");
function remoteFullscreenState() {
  const active =
    document.fullscreenElement === remote ||
    remote.classList.contains("theater");
  fullscreenButton.textContent = active
    ? "✕ EXIT FULL SCREEN"
    : "⛶ FULL SCREEN";
}
fullscreenButton.onclick = async () => {
  if (document.fullscreenElement) {
    await document.exitFullscreen();
    remote.classList.remove("theater");
  } else if (remote.classList.contains("theater")) {
    remote.classList.remove("theater");
  } else {
    remote.classList.add("theater");
    try {
      await remote.requestFullscreen?.({ navigationUI: "hide" });
    } catch {}
    screen.orientation?.lock?.("landscape").catch(() => {});
  }
  remoteFullscreenState();
};
document.addEventListener("fullscreenchange", () => {
  if (!document.fullscreenElement) remote.classList.remove("theater");
  remoteFullscreenState();
});
const portrait = {
  stick: [5, 31],
  dpad: [5, 31],
  l1: [3, 3],
  l2: [24, 3],
  r2: [58, 3],
  r1: [79, 3],
  y: [73, 24],
  x: [62, 40],
  b: [84, 40],
  a: [73, 56],
  select: [38, 80],
  start: [57, 80],
};
const landscape = {
  stick: [4, 30],
  dpad: [4, 30],
  l1: [2, 3],
  l2: [18, 3],
  r2: [68, 3],
  r1: [84, 3],
  y: [82, 21],
  x: [75, 40],
  b: [89, 40],
  a: [82, 59],
  select: [42, 75],
  start: [54, 75],
};
const dualPortrait = {
  ...portrait,
  dpad: [3, 20],
  stick: [5, 60],
  y: [74, 24],
  x: [62, 41],
  b: [86, 41],
  a: [74, 58],
  select: [48, 80],
  start: [67, 80],
};
const dualLandscape = {
  ...landscape,
  dpad: [3, 35],
  stick: [25, 35],
  y: [82, 20],
  x: [74, 39],
  b: [90, 39],
  a: [82, 58],
  select: [43, 72],
  start: [55, 72],
};
const presets = {
  arcade: {
    show: [
      "stick",
      "l1",
      "l2",
      "r1",
      "r2",
      "a",
      "b",
      "x",
      "y",
      "select",
      "start",
    ],
    labels: { a: "A", b: "B", x: "X", y: "Y" },
  },
  nes: {
    show: ["dpad", "a", "b", "select", "start"],
    labels: { a: "A", b: "B" },
  },
  snes: {
    show: ["dpad", "l1", "r1", "a", "b", "x", "y", "select", "start"],
    labels: { a: "A", b: "B", x: "X", y: "Y" },
  },
  genesis: {
    show: ["dpad", "l1", "r1", "a", "b", "x", "y", "select", "start"],
    labels: { a: "A", b: "B", x: "C", y: "Z", l1: "X", r1: "Y" },
  },
  dreamcast: {
    show: ["stick", "dpad", "l1", "r1", "a", "b", "x", "y", "start"],
    labels: { a: "A", b: "B", x: "X", y: "Y" },
  },
  modern: {
    show: [
      "stick",
      "dpad",
      "l1",
      "l2",
      "r1",
      "r2",
      "a",
      "b",
      "x",
      "y",
      "select",
      "start",
    ],
    labels: { a: "A", b: "B", x: "X", y: "Y" },
  },
};
function orientation() {
  return matchMedia("(orientation:landscape)").matches
    ? "landscape"
    : "portrait";
}
function layoutKey() {
  return `dwPadLayoutV2-${themeSelect.value}-${orientation()}`;
}
function defaultPositions() {
  const dual =
    themeSelect.value === "dreamcast" || themeSelect.value === "modern";
  return orientation() === "landscape"
    ? dual
      ? dualLandscape
      : landscape
    : dual
      ? dualPortrait
      : portrait;
}
function applyLayout(saved) {
  const base = defaultPositions();
  $$(".control").forEach((c) => {
    const item = saved?.[c.dataset.control],
      pos = item?.pos || item || base[c.dataset.control];
    if (pos) {
      c.style.left = pos[0] + "%";
      c.style.top = pos[1] + "%";
    }
    const scale = item?.scale || 1;
    c.dataset.scale = scale;
    c.style.setProperty("--control-scale", scale);
  });
}
async function setTheme(name, reset = false) {
  themeSelect.value = name;
  stage.className = `controller theme-${name}${editing ? "" : " locked"}`;
  const p = presets[name];
  $$(".control").forEach((c) => {
    c.style.display = p.show.includes(c.dataset.control) ? "" : "none";
    const label = p.labels[c.dataset.control];
    if (label && c.tagName === "BUTTON") c.textContent = label;
  });
  let saved = reset
    ? null
    : JSON.parse(localStorage.getItem(layoutKey()) || "null");
  applyLayout(saved);
  localStorage.dwPadTheme = name;
  if (!reset) await loadRemoteLayout(name);
}
async function loadRemoteLayout(name) {
  if (!token || session?.role !== "user") return;
  try {
    const r = await api(`/api/layout/v2-${name}-${orientation()}`);
    if (r.layout) {
      localStorage.setItem(layoutKey(), JSON.stringify(r.layout));
      applyLayout(r.layout);
    }
  } catch {}
}
themeSelect.onchange = () => setTheme(themeSelect.value);
function layoutData() {
  const r = stage.getBoundingClientRect(),
    out = {};
  $$(".control").forEach((c) => {
    out[c.dataset.control] = {
      pos: [
        +((c.offsetLeft / r.width) * 100).toFixed(2),
        +((c.offsetTop / r.height) * 100).toFixed(2),
      ],
      scale: +(c.dataset.scale || 1),
    };
  });
  return out;
}
async function saveLayout() {
  const out = layoutData();
  localStorage.setItem(layoutKey(), JSON.stringify(out));
  if (session?.role === "user")
    try {
      await api(`/api/layout/v2-${themeSelect.value}-${orientation()}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ layout: out }),
      });
      toast("Layout saved to your profile");
    } catch (e) {
      toast("Saved on this phone");
    }
}
$("#editLayout").onclick = () => {
  editing = !editing;
  selected = null;
  stage.classList.toggle("locked", !editing);
  $("#editLayout").textContent = editing ? "🔓 UNLOCKED" : "🔒 LOCKED";
  $("#layoutHint").textContent = editing
    ? "Tap a control to select it, drag to move, and use SIZE to resize. Lock when done."
    : "Rotate to landscape for a full-width gamepad. Unlock to customize.";
  if (!editing) saveLayout();
};
$("#resetLayout").onclick = () => {
  localStorage.removeItem(layoutKey());
  applyLayout(null);
  toast("Layout reset for this orientation");
};
function resizeSelected(delta) {
  if (!editing) return toast("Unlock the layout first");
  if (!selected) return toast("Tap a control first");
  const scale = Math.max(
    0.55,
    Math.min(1.8, +(selected.dataset.scale || 1) + delta),
  );
  selected.dataset.scale = scale;
  selected.style.setProperty("--control-scale", scale);
  saveLayout();
}
$("#sizeDown").onclick = () => resizeSelected(-0.1);
$("#sizeUp").onclick = () => resizeSelected(0.1);
$$(".control").forEach((c) =>
  c.addEventListener(
    "pointerdown",
    (e) => {
      if (!editing) return;
      e.preventDefault();
      e.stopImmediatePropagation();
      selected?.classList.remove("selected");
      selected = c;
      c.classList.add("selected");
      c.setPointerCapture(e.pointerId);
      const sr = stage.getBoundingClientRect(),
        cr = c.getBoundingClientRect(),
        dx = e.clientX - cr.left,
        dy = e.clientY - cr.top;
      const move = (m) => {
        let left = Math.max(
            0,
            Math.min(sr.width - cr.width, m.clientX - sr.left - dx),
          ),
          top = Math.max(
            0,
            Math.min(sr.height - cr.height, m.clientY - sr.top - dy),
          );
        c.style.left = (left / sr.width) * 100 + "%";
        c.style.top = (top / sr.height) * 100 + "%";
      };
      c.onpointermove = move;
      c.onpointerup = () => {
        c.onpointermove = null;
        c.onpointerup = null;
        saveLayout();
      };
    },
    true,
  ),
);
addEventListener("orientationchange", () =>
  setTimeout(() => setTheme(themeSelect.value), 250),
);
async function action(name) {
  try {
    const r = await api("/api/action", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ action: name }),
    });
    if (!name.startsWith("nav-")) toast(r.message || "Command sent");
    if (
      (name === "close-game" || name === "restart-menu") &&
      $("#remote").classList.contains("active")
    )
      scheduleRemoteResync(3000);
  } catch (e) {
    toast(e.message);
  }
}
$$("[data-action]").forEach(
  (b) => (b.onclick = () => action(b.dataset.action)),
);
$("#player1").onclick = () => action("mobile-player1");
function human(n) {
  for (const u of ["B", "KB", "MB", "GB", "TB"]) {
    if (n < 1024) return `${n.toFixed(u === "B" ? 0 : 1)} ${u}`;
    n /= 1024;
  }
}
const statPage = {};
let lastStatus = null;
function statDefinitions(s) {
  const f = (s.temperature * 9) / 5 + 32,
    used = s.disk.total - s.disk.free;
  return {
    CPU: [
      ["CPU", s.cpu + "%"],
      ["LOAD", s.load_percent + "%"],
      ["CORES", navigator.hardwareConcurrency || "—"],
    ],
    TEMP: [
      ["TEMP", s.temperature + "°C"],
      ["TEMP", f.toFixed(1) + "°F"],
      ["THERMAL", s.temperature < 70 ? "COOL" : "WARM"],
    ],
    MEMORY: [
      ["MEMORY", s.memory.percent + "%"],
      ["RAM USED", human(s.memory.used)],
      ["RAM TOTAL", human(s.memory.total)],
    ],
    DISK: [
      ["DISK FREE", human(s.disk.free)],
      ["DISK USED", human(used)],
      ["DISK FULL", s.disk.percent + "%"],
    ],
    UPTIME: [
      ["UPTIME", Math.floor(s.uptime / 3600) + "h"],
      ["UPTIME", Math.floor(s.uptime / 60) + " min"],
      ["HOST", s.hostname],
    ],
    GAME: [
      ["GAME", s.game || "Menu"],
      ["JUKEBOX", s.music.status || "stopped"],
      ["TRACK", s.music.title || "None"],
    ],
    USERS: [
      ["CONNECTED", s.connected_controllers],
      ["SESSIONS", s.active_sessions],
      ["PHONE PAD", s.mobile_gamepad_index ?? "—"],
    ],
    FAN: [
      ["FAN", s.fan?.connected ? s.fan.speed + "%" : "NOT FOUND"],
      ["FAN MODE", s.fan?.connected ? "AUTOMATIC" : "CHECK HAT"],
      ["FAN STATUS", s.fan?.message || "Starting"],
    ],
    POWER: [
      ["POWER", s.power_status],
      ["RAW CHECK", s.throttled],
      ["BATTERY", s.battery.available ? s.battery.percent + "%" : "—"],
    ],
  };
}
function drawStats() {
  if (!lastStatus) return;
  const defs = statDefinitions(lastStatus);
  $("#stats").innerHTML = Object.entries(defs)
    .map(([key, pages]) => {
      const p = pages[(statPage[key] || 0) % pages.length];
      return `<button class="stat" data-stat="${key}">${esc(p[0])}<b>${esc(p[1])}</b><small>tap for more</small></button>`;
    })
    .join("");
  $$("[data-stat]").forEach(
    (b) =>
      (b.onclick = () => {
        statPage[b.dataset.stat] = (statPage[b.dataset.stat] || 0) + 1;
        drawStats();
      }),
  );
}
async function refresh() {
  try {
    const s = await api("/api/status"),
      gameNow = !!s.game;
    if (
      remoteGameState !== null &&
      remoteGameState !== gameNow &&
      $("#remote").classList.contains("active")
    )
      scheduleRemoteResync(500);
    remoteGameState = gameNow;
    lastStatus = s;
    drawStats();
    $("#song").textContent =
      `${s.music.title || "No track"} • ${s.music.status || "stopped"} • jukebox ${s.music.volume || 0}% • master ${s.master_volume ?? "—"}% • ${s.music.message || ""}`;
    if (s.battery.available) {
      const estimate =
        s.battery.remaining_hours != null
          ? ` • about ${s.battery.remaining_hours}h remaining`
          : " • learning drain rate";
      $("#battery").textContent = `${s.battery.percent}% estimated${estimate}`;
    } else $("#battery").textContent = s.battery.reason;
  } catch (e) {}
  setTimeout(refresh, 3000);
}
$("#setBattery").onclick = async () => {
  const percent = Number($("#batteryPercent").value);
  if (!Number.isFinite(percent) || percent < 0 || percent > 100)
    return toast("Enter 0–100");
  try {
    const r = await api("/api/battery", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ percent }),
    });
    toast(
      r.learning
        ? "Reading saved — learning drain rate"
        : "Reading saved — estimate updated",
    );
    refresh();
  } catch (e) {
    toast(e.message);
  }
};
$("#category").onchange = () =>
  ($("#romSystem").hidden = $("#category").value !== "roms");
$("#upload").onclick = async () => {
  const files = [...$("#files").files];
  if (!files.length) return;
  const cfg = await api("/api/settings");
  if (!cfg.uploads_enabled)
    return toast("Uploads are disabled in Admin settings");
  const limit = (cfg.large_uploads ? 4096 : cfg.normal_limit_mb) * 1024 * 1024;
  const tooBig = files.find((f) => f.size > limit);
  if (tooBig)
    return toast(
      `${tooBig.name} exceeds the ${cfg.large_uploads ? "4 GB" : cfg.normal_limit_mb + " MB"} limit`,
    );
  let done = 0;
  for (const file of files) {
    const fd = new FormData();
    fd.append("file", file);
    let url = `/api/upload/${$("#category").value}`;
    if ($("#category").value === "roms")
      url += `?system=${encodeURIComponent($("#romSystem").value)}`;
    try {
      const r = await fetch(url, {
        method: "POST",
        headers: { Authorization: `Bearer ${token}` },
        body: fd,
      });
      if (!r.ok) throw new Error(await r.text());
      done++;
      $("#progress").value = (done / files.length) * 100;
      $("#uploadMsg").textContent =
        `Uploaded ${done}/${files.length}: ${file.name}`;
    } catch (e) {
      toast(e.message);
      break;
    }
  }
  loadLibrary();
};
function openViewer(url, kind, name) {
  $("#viewerTitle").textContent = name;
  $("#viewerDownload").href = url;
  $("#viewerDownload").download = name;
  $("#viewerBody").innerHTML =
    kind === "images"
      ? `<img src="${url}" alt="${esc(name)}">`
      : kind === "videos"
        ? `<video src="${url}" controls autoplay playsinline></video>`
        : `<audio src="${url}" controls autoplay></audio>`;
  $("#mediaViewer").hidden = false;
  document.body.classList.add("viewerOpen");
}
function closeViewer() {
  const media = $("#viewerBody").querySelector("video,audio");
  media?.pause();
  media?.removeAttribute("src");
  $("#viewerBody").innerHTML = "";
  $("#mediaViewer").hidden = true;
  document.body.classList.remove("viewerOpen");
}
$("#closeViewer").onclick = closeViewer;
$("#mediaViewer").onclick = (e) => {
  if (e.target === $("#mediaViewer")) closeViewer();
};
addEventListener("keydown", (e) => {
  if (e.key === "Escape") closeViewer();
});
async function loadLibrary() {
  try {
    const d = await api("/api/media");
    const blocks = [];
    for (const [kind, files] of Object.entries(d.items)) {
      if (!files.length) continue;
      blocks.push(`<h2 class="mediaHeading">${kind.toUpperCase()}</h2>`);
      for (const f of files.slice(0, kind === "videos" ? 30 : 60)) {
        let player =
          kind === "images"
            ? `<img src="${f.url}" loading="lazy" alt="">`
            : kind === "videos"
              ? `<video src="${f.url}" controls preload="none"></video>`
              : `<audio src="${f.url}" controls preload="none"></audio>`;
        blocks.push(
          `<article class="mediaItem">${player}<div title="${esc(f.name)}">${esc(f.name)}</div><small>${human(f.bytes)}</small><div class="mediaActions"><button data-view="${f.url}" data-kind="${kind}" data-name="${esc(f.name)}">${kind === "images" ? "VIEW" : "PLAY"}</button><a href="${f.url}" download="${esc(f.name)}">DOWNLOAD</a></div>${d.admin ? `<button class="danger" data-delete="${kind}" data-file="${encodeURIComponent(f.name)}">DELETE</button>` : ""}</article>`,
        );
      }
    }
    $("#libraryItems").innerHTML =
      blocks.join("") || '<div class="card">No uploaded media yet.</div>';
    $$("[data-delete]").forEach(
      (b) =>
        (b.onclick = async () => {
          if (!confirm(`Delete ${decodeURIComponent(b.dataset.file)}?`)) return;
          await api(`/api/media/${b.dataset.delete}/${b.dataset.file}`, {
            method: "DELETE",
          });
          toast("File deleted");
          loadLibrary();
        }),
    );
  } catch (e) {
    $("#libraryItems").innerHTML = `<div class="card">${esc(e.message)}</div>`;
  }
}
$("#refreshLibrary").onclick = loadLibrary;
$("#libraryItems").onclick = (e) => {
  const card = e.target.closest(".mediaItem");
  if (!card) return;
  const trigger =
    e.target.closest("[data-view]") ||
    (e.target.matches("img,video") ? card.querySelector("[data-view]") : null);
  if (!trigger) return;
  e.preventDefault();
  openViewer(trigger.dataset.view, trigger.dataset.kind, trigger.dataset.name);
};
async function loadSettings() {
  try {
    const s = await api("/api/settings");
    $("#mediaEnabled").checked = s.media_enabled;
    $("#uploadsEnabled").checked = s.uploads_enabled;
    $("#largeUploads").checked = s.large_uploads;
    $("#uploadLimit").value = s.normal_limit_mb;
    $("#launchPolicy").value = s.party_launch_policy || "any_queued";
  } catch (e) {
    toast(e.message);
  }
}
async function loadFan() {
  try {
    const f = await api("/api/fan");
    $("#fanProfile").value = f.profile || "balanced";
    $("#fanNow").textContent = f.state?.connected
      ? `${f.state.temperature}°C • ${f.state.speed}% • ${f.state.message}`
      : "Fan HAT not responding";
  } catch (e) {
    $("#fanNow").textContent = e.message;
  }
}
async function setFan(mode, speed = null) {
  try {
    await api("/api/fan", {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        mode,
        profile: $("#fanProfile").value,
        speed,
        minutes: 5,
      }),
    });
    toast(
      mode === "auto"
        ? "Automatic fan control saved"
        : `Fan test set to ${speed}%`,
    );
    setTimeout(loadFan, 900);
  } catch (e) {
    toast(e.message);
  }
}
$("#fanAuto").onclick = () => setFan("auto");
$("#fan50").onclick = () => setFan("manual", 50);
$("#fan100").onclick = () => setFan("manual", 100);
$("#fanProfile").onchange = () => setFan("auto");
let audioState = {};
async function loadAudio() {
  if (session?.role !== "admin") return toast("Administrator login required");
  try {
    audioState = await api("/api/audio");
    for (const n of ["master", "music", "menu"]) {
      const v = audioState[n + "_volume"] ?? 0;
      $("#" + n + "Slider").value = v;
      $("#" + n + "Level").textContent = v + "%";
      $("#" + n + "Mute").textContent = audioState[n + "_muted"]
        ? "UNMUTE"
        : "MUTE";
    }
  } catch (e) {
    toast(e.message);
  }
}
async function saveAudio(target, muted = audioState[target + "_muted"]) {
  const volume = +$("#" + target + "Slider").value;
  try {
    audioState = await api("/api/audio", {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ target, volume, muted }),
    });
    $("#" + target + "Level").textContent = volume + "%";
    $("#" + target + "Mute").textContent = audioState[target + "_muted"]
      ? "UNMUTE"
      : "MUTE";
  } catch (e) {
    toast(e.message);
  }
}
for (const n of ["master", "music", "menu"]) {
  $("#" + n + "Slider").oninput = () =>
    ($("#" + n + "Level").textContent = $("#" + n + "Slider").value + "%");
  $("#" + n + "Slider").onchange = () => saveAudio(n);
  $("#" + n + "Mute").onclick = () => saveAudio(n, !audioState[n + "_muted"]);
}
$("#saveSettings").onclick = async () => {
  try {
    await api("/api/settings", {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        media_enabled: $("#mediaEnabled").checked,
        uploads_enabled: $("#uploadsEnabled").checked,
        large_uploads: $("#largeUploads").checked,
        normal_limit_mb: +$("#uploadLimit").value,
        party_launch_policy: $("#launchPolicy").value,
      }),
    });
    toast("Media settings saved");
  } catch (e) {
    toast(e.message);
  }
};
async function loadUsers() {
  try {
    const d = await api("/api/admin/users");
    $("#users").innerHTML =
      d.users
        .map(
          (u) =>
            `<div class="userrow"><b>${esc(u.username)}</b> ${esc(u.email || "")} • ${u.login_count} visits <button data-reset="${u.id}">RESET PASSWORD</button></div>`,
        )
        .join("") || "No saved players yet";
    $("#activity").innerHTML = d.activity
      .map(
        (a) =>
          `<div class="activity">${new Date(a.at * 1000).toLocaleString()} • ${esc(a.actor)} • ${esc(a.event)}${a.detail ? " • " + esc(a.detail) : ""}</div>`,
      )
      .join("");
    $$("[data-reset]").forEach(
      (b) =>
        (b.onclick = async () => {
          const p = prompt("New password (leave blank to remove it):");
          if (p === null) return;
          await api("/api/admin/reset-password", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ user_id: +b.dataset.reset, password: p }),
          });
          toast("Password reset");
          loadUsers();
        }),
    );
  } catch (e) {
    toast(e.message);
  }
}
$("#loadUsers").onclick = loadUsers;
let partySocket = null;
let selectedGame = null;
let remoteHandoffId = null;
function drawGameChoice(choice) {
  selectedGame = choice || null;
  $("#gameChoice").hidden = !choice;
  if (!choice) return;
  $("#choiceTitle").textContent = choice.title;
  $("#choiceSystem").textContent = String(choice.system || "").toUpperCase();
  $("#choicePlayer").textContent = choice.selected_by;
  const busy = choice.status !== "selected";
  $("#choiceStatus").textContent = busy ? choice.status.replaceAll("-", " ").toUpperCase() : "Ready to start on the cabinet.";
  $("#confirmGame").disabled = busy;
  $("#cancelGame").disabled = busy;
}
function drawParty(state) {
  const queue = state.queue || [];
  document.body.dataset.arcadeMode = state.mode || "classic";
  $("#arcadeModeLabel").textContent = (state.mode || "classic").toUpperCase();
  drawGameChoice(state.selected_game);
  const choice = state.selected_game;
  if (choice && choice.status !== "selected" && remoteHandoffId !== choice.id) {
    remoteHandoffId = choice.id;
    toast(`Launching ${choice.title} — opening Remote Play`);
    document.querySelector('[data-tab="remote"]')?.click();
    scheduleRemoteResync(1200);
  }
  if (!choice) remoteHandoffId = null;
  const invited = state.invited;
  const mine = invited && invited.name === session?.name;
  $("#turnInvite").hidden = !mine;
  if (mine) {
    const seconds = Math.max(0, Math.ceil((invited.invited_until - (state.server_time || Date.now()/1000))));
    $("#turnCountdown").textContent = seconds + " seconds to accept";
    if (!window.dwLastInvite || window.dwLastInvite !== invited.id) {
      window.dwLastInvite = invited.id;
      if (Notification.permission === "granted") new Notification("Dreadwire Arcade: your turn!", {body:"Come to the cabinet and tap Accept within one minute."});
      else if (Notification.permission === "default") Notification.requestPermission();
      navigator.vibrate?.([250,100,250,100,500]);
    }
  }
  $("#partyQueue").innerHTML = queue.length
    ? queue.map((p, index) => '<div class="queuePlayer ' + p.state + '"><b>' + (p.state === "active" ? "PLAYING" : p.state === "invited" ? "CALLING NOW" : "#" + (index + 1)) + '</b><span>' + esc(p.name) + '</span>' + (session?.role === "admin" ? '<button data-queue-remove="' + p.id + '">REMOVE</button>' : "") + '</div>').join("")
    : '<p class="hint">The queue is open—be the first player.</p>';
  $("#partyChat").innerHTML = (state.chat || []).map((m) => '<div class="chatLine"><time>' + new Date(m.at*1000).toLocaleTimeString([], {hour:"2-digit",minute:"2-digit"}) + '</time><b>' + esc(m.sender) + ':</b> <span>' + esc(m.message) + '</span></div>').join("") || '<p class="hint">Chat is quiet.</p>';
  $("#partyChat").scrollTop = $("#partyChat").scrollHeight;
  $$('[data-queue-remove]').forEach((button) => button.onclick = () => changeQueue("remove", "", +button.dataset.queueRemove));
}
async function loadParty() {
  try {
    drawParty(await api("/api/party"));
    const telemetry = await api("/api/telemetry/controllers");
    $("#controllerTelemetry").innerHTML = telemetry.controllers.length
      ? telemetry.controllers.map((c, i) => '<div class="controllerStat"><b>P' + (i + 1) + ' • ' + esc(c.name) + '</b><span>' + esc(c.connection) + ' • ' + (c.battery == null ? "battery unavailable" : c.battery + "%") + (c.charging ? " • " + esc(c.charging) : "") + '</span></div>').join("")
      : '<p class="hint">No physical gamepads detected.</p>';
  } catch (e) { toast(e.message); }
  if (!partySocket || partySocket.readyState > 1) {
    const scheme = location.protocol === "https:" ? "wss" : "ws";
    partySocket = new WebSocket(scheme + "://" + location.host + "/ws/party?token=" + encodeURIComponent(token));
    partySocket.onmessage = (event) => { try { const data = JSON.parse(event.data); if (data.type === "state") drawParty(data); } catch (_) {} };
  }
  loadScores();
}
async function changeQueue(action, name = "", id = 0, minutes = 1) {
  try {
    const state = await api("/api/party/queue", {method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({action,name,id,minutes})});
    drawParty(state);
    toast(action === "join" ? "You joined the player queue" : action === "advance" ? "Queue advanced" : "Queue updated");
  } catch (e) { toast(e.message); }
}
$("#joinQueue").onclick = () => changeQueue("join");
$("#leaveQueue").onclick = () => changeQueue("leave");
$("#acceptTurn").onclick = () => changeQueue("accept");
$("#extendQueue").onclick = () => changeQueue("extend", "", 0, 1);
$("#advanceQueue").onclick = () => changeQueue("advance");
$("#clearQueue").onclick = () => confirm("Clear the entire player queue?") && changeQueue("clear");
function sendPartyChat() {
  const message=$("#chatMessage").value.trim();
  if (!message || !partySocket || partySocket.readyState !== WebSocket.OPEN) return;
  partySocket.send(JSON.stringify({type:"chat",message})); $("#chatMessage").value="";
}
$("#sendChat").onclick = sendPartyChat;
$("#chatMessage").onkeydown = (event) => { if (event.key === "Enter") sendPartyChat(); };
async function searchGameCatalog() {
  const query = $("#gameSearch").value.trim();
  if (query.length < 2) return toast("Enter at least two letters");
  try {
    const data = await api("/api/games/search?q=" + encodeURIComponent(query));
    $("#gameResults").innerHTML = data.games.length ? data.games.map((g) => '<div class="gameResult"><button data-score-game="' + encodeURIComponent(g.title) + '"><b>' + esc(g.title) + '</b><span>' + esc(g.system.toUpperCase()) + '</span></button><button data-select-title="' + encodeURIComponent(g.title) + '" data-select-system="' + encodeURIComponent(g.system) + '" data-select-path="' + encodeURIComponent(g.path) + '">SELECT</button></div>').join("") : '<p class="hint">No matching games.</p>';
    $$('[data-score-game]').forEach((button) => button.onclick = () => { $("#scoreGame").value = decodeURIComponent(button.dataset.scoreGame); loadScores(); });
    $$('[data-select-system]').forEach((button) => button.onclick = async () => { try { const result=await api("/api/games/select",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({title:decodeURIComponent(button.dataset.selectTitle),system:decodeURIComponent(button.dataset.selectSystem),path:decodeURIComponent(button.dataset.selectPath)})}); toast(result.message); } catch(e) { toast(e.message); } });
  } catch (e) { toast(e.message); }
}
$("#searchGames").onclick = searchGameCatalog;
$("#gameSearch").onkeydown = (event) => { if (event.key === "Enter") searchGameCatalog(); };
async function loadScores() {
  try {
    const game = $("#scoreGame").value.trim();
    const data = await api("/api/scores" + (game ? "?game=" + encodeURIComponent(game) : ""));
    $("#scoreBoard").innerHTML = data.scores.length ? data.scores.map((s, i) => '<div class="scoreRow"><b>' + (i + 1) + ". " + esc(s.username) + '</b><span>' + esc(s.game_title) + " • " + Number(s.score).toLocaleString() + '</span></div>').join("") : '<p class="hint">No scores submitted yet.</p>';
  } catch (e) { toast(e.message); }
}
$("#submitScore").onclick = async () => {
  const game = $("#scoreGame").value.trim(), score = Number($("#scoreValue").value);
  if (!game || !Number.isInteger(score) || score < 0) return toast("Enter a game and whole-number score");
  try { await api("/api/scores", {method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({game,score})}); $("#scoreValue").value = ""; toast("Score added"); loadScores(); } catch (e) { toast(e.message); }
};
$("#confirmGame").onclick = async () => {
  if (!selectedGame) return;
  try { const result=await api("/api/games/launch",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({selection_id:selectedGame.id})}); toast(result.message); } catch(e) { toast(e.message); }
};
$("#cancelGame").onclick = async () => {
  try { await api("/api/games/select",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({action:"clear"})}); } catch(e) { toast(e.message); }
};
async function loadWifi() {
  if (session?.role !== "admin") return;
  $("#wifiNetworks").innerHTML = '<p class="hint">Scanning…</p>';
  try {
    const d = await api("/api/wifi");
    $("#wifiNetworks").innerHTML =
      d.networks
        .map(
          (n) =>
            `<button class="wifiNetwork ${n.active ? "connected" : ""}" data-ssid="${encodeURIComponent(n.ssid)}"><b>${esc(n.ssid)}</b><span>${n.active ? "CONNECTED • " : ""}${n.signal}% • ${esc(n.security)}</span></button>`,
        )
        .join("") || '<p class="hint">No nearby networks found.</p>';
    $("#savedWifi").innerHTML =
      d.connections
        .map(
          (name) =>
            `<div class="savedNetwork"><span>${esc(name)}</span><button data-forget="${encodeURIComponent(name)}">FORGET</button></div>`,
        )
        .join("") || '<p class="hint">No saved Wi-Fi networks.</p>';
    $$("[data-ssid]").forEach(
      (button) =>
        (button.onclick = async () => {
          const ssid = decodeURIComponent(button.dataset.ssid);
          if (button.classList.contains("connected"))
            return toast(`Already connected to ${ssid}`);
          const password = prompt(
            `Password for ${ssid} (leave blank for an open network):`,
          );
          if (password === null) return;
          try {
            const r = await api("/api/wifi/connect", {
              method: "POST",
              headers: { "Content-Type": "application/json" },
              body: JSON.stringify({ ssid, password }),
            });
            toast(r.message);
            setTimeout(loadWifi, 1500);
          } catch (e) {
            toast(e.message);
          }
        }),
    );
    $$("[data-forget]").forEach(
      (button) =>
        (button.onclick = async () => {
          const name = decodeURIComponent(button.dataset.forget);
          if (!confirm(`Forget ${name}?`)) return;
          try {
            const r = await api("/api/wifi/forget", {
              method: "POST",
              headers: { "Content-Type": "application/json" },
              body: JSON.stringify({ name }),
            });
            toast(r.message);
            loadWifi();
          } catch (e) {
            toast(e.message);
          }
        }),
    );
  } catch (e) {
    $("#wifiNetworks").innerHTML = `<p>${esc(e.message)}</p>`;
  }
}
$("#scanWifi").onclick = loadWifi;
async function checkForUpdates(force = false) {
  try {
    const update = await api("/api/update");
    if (!update.configured) return;
    if (
      !force &&
      (!update.available || localStorage.dwUpdateSeen === update.latest)
    )
      return;
    $("#updateTitle").textContent = update.available
      ? `Version ${update.latest} is ready`
      : `Version ${update.current} is current`;
    $("#updateNotes").innerHTML =
      `<p>Installed: ${esc(update.current)}</p>${update.notes?.length ? `<ul>${update.notes.map((n) => `<li>${esc(n)}</li>`).join("")}</ul>` : "<p>Maintenance and cabinet improvements.</p>"}`;
    $("#installUpdate").hidden = !update.available || session?.role !== "admin";
    $("#updateViewer").hidden = false;
    localStorage.dwUpdateSeen = update.latest;
  } catch {}
}
$("#closeUpdate").onclick = $("#laterUpdate").onclick = () =>
  ($("#updateViewer").hidden = true);
$("#installUpdate").onclick = async () => {
  try {
    const r = await api("/api/update/install", { method: "POST" });
    toast(r.message);
    $("#updateViewer").hidden = true;
  } catch (e) {
    toast(e.message);
  }
};
document.addEventListener(
  "touchmove",
  (e) => {
    if (document.body.classList.contains("pad-active")) e.preventDefault();
  },
  { passive: false },
);
if ("serviceWorker" in navigator)
  navigator.serviceWorker.register("/static/sw.js?v=25");
syncPadMode();
setTheme(localStorage.dwPadTheme || "arcade");
if (token) enter();
