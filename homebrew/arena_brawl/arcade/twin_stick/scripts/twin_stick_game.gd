extends Node2D
## Self-contained playable reference demo, separate from your main game's files.
## Portrait 768x1024 cabinet design. Body direction and weapon angle are independent.
## Manual collision simulation continues when embedded in a paused SceneTree.
signal close_requested
const BASE = "res://arcade/twin_stick/"
const ART = BASE + "assets/"
const LIBRARY = preload("res://arcade/twin_stick/scripts/asset_library.gd")
const AUDIO = preload("res://arcade/twin_stick/scripts/audio_director.gd")
const INPUT_SETUP = preload("res://arcade/twin_stick/scripts/input_setup.gd")
const DIRS = ["s", "sw", "w", "nw", "n", "ne", "e", "se"]
const ROOM = Rect2(55, 175, 658, 770)
var library = LIBRARY.new()
var audio
var players: Array = []
var enemies: Array = []
var shots: Array = []
var drops: Array = []
var effects: Array = []
var hazards: Array = []
var popups: Array = []
var enemy_defs: Dictionary = {}
var boss_defs: Dictionary = {}
var weapons: Dictionary = {}
var weapon_ids: Array = []
var waves: Array = []
var pickup_ids: Array = []
var game_time: float = 0.0
var wave_index: int = 0
var phase: String = "warning"
var phase_timer: float = 1.5
var demo_paused: bool = false
var game_over: bool = false
var victory: bool = false
var god_mode: bool = false
var debug_info: bool = false
var show_help: bool = false
var p2_enabled: bool = true
var score_multiplier: int = 1
var font: Font
var crt_layer: CanvasLayer
var crt_rect: ColorRect
var texture_seed: int = 0
var shake: float = 0.0
var next_enemy_uid: int = 1
var exit_armed_until: float = 0.0

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    INPUT_SETUP.install()
    randomize()
    font = ThemeDB.fallback_font
    for definition in library.data("enemies"):
        enemy_defs[definition["id"]] = definition
    for definition in library.data("bosses"):
        boss_defs[definition["id"]] = definition
    for definition in library.data("weapons"):
        weapons[definition["id"]] = definition
        weapon_ids.append(definition["id"])
    for definition in library.data("prizes"):
        pickup_ids.append(definition["id"])
    waves = library.data("waves")
    audio = AUDIO.new()
    add_child(audio)
    _make_crt()
    restart()

func restart() -> void:
    enemies.clear()
    shots.clear()
    drops.clear()
    effects.clear()
    hazards.clear()
    popups.clear()
    players = [_new_player(0, Vector2(280, 545)), _new_player(1, Vector2(488, 545))]
    wave_index = 0
    game_time = 0.0
    phase = "warning"
    phase_timer = 2.0
    game_over = false
    victory = false
    demo_paused = false
    if audio != null:
        audio.stop_all()
        audio.play_music("arena_combat_01")
        audio.announce("game_start", true)
    for i in range(weapon_ids.size()):
        drops.append({"kind": "weapon", "id": weapon_ids[i], "pos": Vector2(155 + (i % 5) * 115, 820 + int(i / 5) * 72), "life": 40.0})

func _new_player(index: int, point: Vector2) -> Dictionary:
    return {"id": index, "name": "volt" if index == 0 else "nova", "pos": point,
        "health": 100.0, "armor": 0.0, "lives": 3, "score": 0,
        "weapon": "pulse_pistol", "fire_timer": 0.0, "aim": Vector2.UP,
        "move": Vector2.ZERO, "dir": "s", "invuln": 2.5,
        "respawn": 0.0, "damage_flash": 0.0, "buffs": {}, "anim_time": 0.0}

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        match event.physical_keycode:
            KEY_ESCAPE:
                close_requested.emit()
                if close_requested.get_connections().is_empty():
                    get_tree().quit()
            KEY_P:
                demo_paused = not demo_paused
            KEY_R:
                restart()
            KEY_TAB:
                p2_enabled = not p2_enabled
            KEY_M:
                audio.toggle_music()
            KEY_C:
                crt_layer.visible = not crt_layer.visible
            KEY_F1:
                show_help = not show_help
            KEY_F2:
                if OS.is_debug_build():
                    debug_info = not debug_info
            KEY_F3:
                if OS.is_debug_build():
                    god_mode = not god_mode
            KEY_F4:
                if OS.is_debug_build():
                    enemies.clear()
                    phase = "clear"
                    phase_timer = 0.2
            KEY_F5:
                if OS.is_debug_build():
                    _spawn_enemy("grunt", Vector2(640, 220), false)
            KEY_F6:
                if OS.is_debug_build():
                    _spawn_enemy("enforcer", Vector2(640, 270), true)
            KEY_F7:
                if OS.is_debug_build():
                    players[0]["health"] = 100.0
                    _cycle_weapon(players[0])
        get_viewport().set_input_as_handled()
    elif event is InputEventJoypadButton and event.pressed:
        if event.button_index == JOY_BUTTON_START:
            if Input.is_joy_button_pressed(event.device, JOY_BUTTON_BACK):
                _request_exit()
                get_viewport().set_input_as_handled()
                return
            demo_paused = not demo_paused
            audio.play_sfx("pause")
            get_viewport().set_input_as_handled()
    elif event is InputEventMouseButton and event.pressed:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            _cycle_weapon(players[0])
            get_viewport().set_input_as_handled()

func _cycle_weapon(player: Dictionary) -> void:
    var i = weapon_ids.find(player["weapon"])
    player["weapon"] = weapon_ids[(i + 1) % weapon_ids.size()]
    audio.play_sfx("weapon_pickup")

func _process(delta: float) -> void:
    var dt = minf(delta, 0.04)
    if not demo_paused and not game_over and not victory:
        game_time += dt
        _update_players(dt)
        _update_waves(dt)
        _update_enemies(dt)
        _update_shots(dt)
        _update_drops(dt)
        _update_hazards(dt)
    _update_visuals(dt if not demo_paused else 0.0)
    shake = move_toward(shake, 0.0, dt * 16.0)
    queue_redraw()

func _request_exit() -> void:
    var now = Time.get_ticks_msec() / 1000.0
    if now <= exit_armed_until:
        get_tree().quit()
        return
    exit_armed_until = now + 2.0
    _popup("PRESS START + SELECT AGAIN TO EXIT", Vector2(384, 500), Color(1.0, 0.85, 0.2))
    audio.play_sfx("pause")

func _active_players() -> Array:
    var output: Array = []
    for p in players:
        if p["id"] == 1 and not p2_enabled:
            continue
        if p["lives"] > 0 and p["respawn"] <= 0.0:
            output.append(p)
    return output

func _nearest_player(point: Vector2) -> Dictionary:
    var result: Dictionary = {}
    var best = INF
    for p in _active_players():
        var distance = point.distance_squared_to(p["pos"])
        if distance < best:
            best = distance
            result = p
    return result

func _clamp_room(point: Vector2, radius: float = 18.0) -> Vector2:
    return Vector2(clampf(point.x, ROOM.position.x + radius, ROOM.end.x - radius),
        clampf(point.y, ROOM.position.y + radius, ROOM.end.y - radius))

func _direction(vector: Vector2) -> String:
    var index = posmod(roundi((vector.angle() - PI / 2.0) / (PI / 4.0)), 8)
    return DIRS[index]

func _update_players(dt: float) -> void:
    var pads = Input.get_connected_joypads()
    for p in players:
        if p["id"] == 1 and not p2_enabled:
            continue
        if p["lives"] <= 0:
            continue
        p["invuln"] = maxf(0, p["invuln"] - dt)
        p["damage_flash"] = maxf(0, p["damage_flash"] - dt)
        p["fire_timer"] = maxf(0, p["fire_timer"] - dt)
        p["anim_time"] += dt
        for key in p["buffs"].keys():
            p["buffs"][key] -= dt
            if p["buffs"][key] <= 0:
                p["buffs"].erase(key)
        if p["respawn"] > 0:
            p["respawn"] -= dt
            if p["respawn"] <= 0:
                p["health"] = 100.0
                p["invuln"] = 3.0
                p["pos"] = Vector2(280 + p["id"] * 208, 545)
                audio.play_sfx("player_respawn")
                _effect("enemy_spawn", p["pos"], 1.0)
            continue
        var prefix = "brawl_p1_" if p["id"] == 0 else "brawl_p2_"
        var move = Input.get_vector(prefix + "left", prefix + "right", prefix + "up", prefix + "down")
        var aim: Vector2 = p["aim"]
        var firing = false
        if p["id"] == 0:
            aim = (get_global_mouse_position() - p["pos"] - Vector2(0, -18)).normalized()
            firing = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_action_pressed("brawl_p1_fire")
            if firing and move.length() > 0.1 and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
                aim = move.normalized()
        else:
            var key_aim = Input.get_vector("brawl_p2_aim_left", "brawl_p2_aim_right", "brawl_p2_aim_up", "brawl_p2_aim_down")
            if key_aim.length() > 0.1:
                aim = key_aim.normalized()
            firing = Input.is_action_pressed("brawl_p2_fire") or key_aim.length() > 0.1
        # Cabinet/first gamepad is P1. A second gamepad or phone becomes P2.
        var pad_slot = p["id"] if p["id"] < pads.size() else -1
        if pad_slot >= 0 and pad_slot < pads.size():
            var device = pads[pad_slot]
            var left = INPUT_SETUP.deadzone(Vector2(Input.get_joy_axis(device, JOY_AXIS_LEFT_X), Input.get_joy_axis(device, JOY_AXIS_LEFT_Y)))
            var right = INPUT_SETUP.deadzone(Vector2(Input.get_joy_axis(device, JOY_AXIS_RIGHT_X), Input.get_joy_axis(device, JOY_AXIS_RIGHT_Y)))
            if left.length() > 0:
                move = left
            if right.length() > 0:
                aim = right.normalized()
                firing = true
            var action_fire = Input.is_joy_button_pressed(device, JOY_BUTTON_A) or Input.is_joy_button_pressed(device, JOY_BUTTON_X)
            firing = firing or action_fire or Input.get_joy_axis(device, JOY_AXIS_TRIGGER_RIGHT) > 0.3
            if firing and right.length() <= 0.1 and left.length() > 0.1:
                aim = left.normalized()
        p["move"] = move
        p["aim"] = aim if aim.length() > 0.01 else Vector2.UP
        if move.length() > 0.01:
            p["dir"] = _direction(move)
        elif firing:
            p["dir"] = _direction(p["aim"])
        var speed = 230.0 * (1.4 if p["buffs"].has("speed_boost") else 1.0)
        p["pos"] = _clamp_room(p["pos"] + move * speed * dt)
        if firing and p["fire_timer"] <= 0:
            _fire_player(p)

func _fire_player(p: Dictionary) -> void:
    if shots.size() > 420:
        return
    var w: Dictionary = weapons[p["weapon"]]
    p["fire_timer"] = w["fire_interval"] * (0.55 if p["buffs"].has("rapid_fire") else 1.0)
    var count = int(w["projectile_count"]) + (2 if p["buffs"].has("spread_shot") else 0)
    var spread = maxf(float(w["spread_degrees"]), 7 if count > 1 else 0)
    var origin: Vector2 = p["pos"] + Vector2(0, -18)
    if w["id"] == "orbit_drone":
        origin += Vector2.from_angle(game_time * 3.0) * 42.0
    var angle: float = p["aim"].angle()
    for j in range(count):
        var direction = Vector2.from_angle(angle + deg_to_rad((j - (count - 1) * 0.5) * spread))
        shots.append({"pos": origin + direction * 28, "old": origin,
            "vel": direction * w["projectile_speed"], "owner": p["id"], "kind": w["projectile"],
            "damage": w["damage"] * (1.6 if p["buffs"].has("damage_boost") else 1),
            "life": w["lifetime"], "pierce": w["piercing"] or p["buffs"].has("piercing"),
            "splash": w["splash_radius"], "chain": w["chain_targets"], "hit_ids": []})
    if w["id"] != "flame_projector" or int(game_time * 10) % 5 == 0:
        audio.play_sfx(w["sound"], randf_range(0.96, 1.04))
    _effect("muzzle_plasma" if w["projectile"] == "plasma" else "muzzle_pulse", origin + p["aim"] * 34, 0.20, angle)

func _hurt_player(p: Dictionary, amount: float) -> void:
    if god_mode or p["invuln"] > 0 or p["buffs"].has("invulnerability") or p["respawn"] > 0:
        return
    var absorbed = minf(p["armor"], amount * 0.7)
    p["armor"] -= absorbed
    p["health"] -= amount - absorbed
    p["invuln"] = 0.8
    p["damage_flash"] = 0.16
    audio.play_sfx("player_hurt")
    _effect("blood_damage", p["pos"], 0.45)
    if p["health"] <= 0:
        p["lives"] -= 1
        p["respawn"] = 2.0
        _effect("explosion_medium", p["pos"], 0.8)
        audio.play_sfx("player_death")
        audio.announce("player_death")
        var remaining = 0
        for player in players:
            if player["id"] == 0 or p2_enabled:
                remaining += player["lives"]
        if remaining == 0:
            game_over = true
            audio.play_music("game_over")
    elif p["health"] < 30:
        audio.announce("player_low_health")

func _update_waves(dt: float) -> void:
    phase_timer -= dt
    if phase == "warning" and phase_timer <= 0:
        _begin_wave()
    elif phase == "combat" and enemies.is_empty():
        phase = "clear"
        phase_timer = 3.0
        audio.play_sfx("wave_clear")
        audio.announce("room_clear")
        _popup("ROOM CLEARED", Vector2(384, 470), Color(0.3, 1, 0.65))
        _add_pickup("prize_box", Vector2(384, 560))
    elif phase == "clear" and phase_timer <= 0:
        wave_index += 1
        if wave_index >= waves.size():
            victory = true
            audio.play_music("victory")
            audio.announce("victory", true)
            return
        phase = "warning"
        phase_timer = 1.4
        audio.play_sfx("door_warning")
        audio.announce("wave_start")

func _begin_wave() -> void:
    var wave: Dictionary = waves[wave_index]
    phase = "combat"
    hazards.clear()
    var doors = [Vector2(384, 180), Vector2(384, 940), Vector2(58, 555), Vector2(710, 555)]
    var pool: Array = wave["enemy_pool"]
    var count = int(wave["count"])
    if not str(wave["boss"]).is_empty():
        count = maxi(4, count / 3)
        _spawn_enemy(wave["boss"], Vector2(384, 260), true)
        audio.play_music("boss_theme")
        audio.announce("final_boss" if wave_index == 19 else "boss_start", true)
    else:
        audio.play_music("arena_combat_02" if wave_index > 8 else "arena_combat_01")
    for j in range(count):
        var point: Vector2 = doors[j % doors.size()] + Vector2(randf_range(-28, 28), randf_range(-28, 28))
        # Move a spawn to the opposite door if a live player is too close.
        var target = _nearest_player(point)
        if not target.is_empty() and point.distance_to(target["pos"]) < 125:
            point = doors[(j + 2) % doors.size()]
        _spawn_enemy(pool[randi() % pool.size()], point, false)
    for j in range(int(wave["hazard_count"])):
        _spawn_hazard(["electric_floor", "flame_vent", "rotating_laser", "crusher"][j % 4], Vector2(225 + (j % 2) * 318, 390 + int(j / 2) * 300))
    audio.play_sfx("door_open")

func _spawn_enemy(id: String, point: Vector2, is_boss: bool) -> void:
    if enemies.size() >= 120:
        return
    var definition: Dictionary = boss_defs[id] if is_boss else enemy_defs[id]
    enemies.append({"id": id, "uid": next_enemy_uid, "pos": _clamp_room(point, 28), "vel": Vector2.ZERO,
        "boss": is_boss, "hp": float(definition["health"]), "max_hp": float(definition["health"]),
        "speed": float(definition["speed"]), "radius": float(definition["radius"]), "dir": "s",
        "timer": randf_range(1.0, 2.2), "flash": 0.0, "attack_flash": 0.0, "spawn": 0.7,
        "attack_index": 0, "score": definition["score"], "anim_time": randf() * 2})
    next_enemy_uid += 1
    _effect("enemy_spawn", point, 0.65)

func _enemy_shot(enemy: Dictionary, direction: Vector2, kind: String = "enemy_bolt", speed: float = 230.0) -> void:
    if shots.size() > 420:
        return
    var origin: Vector2 = enemy["pos"] + Vector2(0, -15)
    shots.append({"pos": origin, "old": origin, "vel": direction * speed, "owner": -1,
        "kind": kind, "damage": 14.0 if not enemy["boss"] else 20.0,
        "life": 5.0, "pierce": false, "splash": 0.0, "chain": 0, "hit_ids": []})

func _update_enemies(dt: float) -> void:
    # Newly spawned enemies are queued separately by boss logic to avoid iteration instability.
    var pending: Array = []
    for enemy in enemies:
        enemy["flash"] = maxf(0, enemy["flash"] - dt)
        enemy["attack_flash"] = maxf(0, enemy["attack_flash"] - dt)
        enemy["anim_time"] += dt
        enemy["spawn"] -= dt
        if enemy["spawn"] > 0 or enemy["hp"] <= 0:
            continue
        var target = _nearest_player(enemy["pos"])
        if target.is_empty():
            continue
        var distance: float = enemy["pos"].distance_to(target["pos"])
        var aim: Vector2 = (target["pos"] - enemy["pos"]).normalized()
        var direction = aim
        var speed = enemy["speed"]
        if enemy["id"] == "runner":
            direction = aim.rotated(sin(game_time * 5 + enemy["uid"]) * 0.55)
        elif enemy["id"] in ["drone", "bomber"]:
            direction = aim if distance > 280 else aim.rotated(PI / 2) if distance > 180 else -aim
        elif enemy["id"] == "turret":
            speed = 0
        enemy["dir"] = _direction(aim)
        enemy["vel"] = direction * speed
        enemy["pos"] = _clamp_room(enemy["pos"] + enemy["vel"] * dt, enemy["radius"])
        if distance < enemy["radius"] + 20:
            _hurt_player(target, 22.0 if enemy["boss"] else float(enemy_defs[enemy["id"]]["contact_damage"]))
        enemy["timer"] -= dt
        if enemy["timer"] > 0:
            continue
        enemy["attack_flash"] = 0.45
        if enemy["boss"]:
            var attack = enemy["attack_index"] % 3
            enemy["attack_index"] += 1
            enemy["timer"] = 1.4 if enemy["hp"] < enemy["max_hp"] * 0.4 else 2.2
            if enemy["id"] == "enforcer":
                if attack == 0:
                    for j in range(11):
                        _enemy_shot(enemy, aim.rotated((j - 5) * 0.13), "enemy_bolt", 290)
                elif attack == 1:
                    _spawn_hazard("crusher", target["pos"])
                    enemy["pos"] = _clamp_room(enemy["pos"] + aim * 65, 48)
                else:
                    for j in range(16):
                        _enemy_shot(enemy, Vector2.from_angle(j * TAU / 16), "enemy_bolt", 215)
            elif enemy["id"] == "prize_crusher":
                for j in range(8):
                    _enemy_shot(enemy, Vector2.from_angle(j * TAU / 8 + game_time), "rocket", 175)
                if attack == 2:
                    _spawn_hazard("mine", target["pos"])
                    _add_pickup("prize_box", _clamp_room(enemy["pos"] + Vector2(80, 80)))
            elif enemy["id"] == "neon_widow":
                for j in range(9):
                    _enemy_shot(enemy, aim.rotated((j - 4) * .17), "arc_bolt", 205)
                if attack == 1:
                    pending.append({"id": "drone", "pos": enemy["pos"] + Vector2(-90, 20)})
                    pending.append({"id": "drone", "pos": enemy["pos"] + Vector2(90, 20)})
                elif attack == 2:
                    _spawn_hazard("electric_floor", target["pos"])
            else:
                for j in range(18):
                    _enemy_shot(enemy, Vector2.from_angle(j * TAU / 18 + game_time * .1), "plasma", 230)
                _spawn_hazard("rotating_laser" if attack == 0 else "electric_floor", target["pos"])
                if attack == 2:
                    pending.append({"id": "heavy", "pos": enemy["pos"] + Vector2(100, 0)})
            audio.play_sfx("laser_charge")
        elif enemy["id"] in ["drone", "turret", "heavy", "shield_guard"]:
            var count = 5 if enemy["id"] == "heavy" else 3 if enemy["id"] == "turret" else 1
            for j in range(count):
                _enemy_shot(enemy, aim.rotated((j - (count - 1) / 2.0) * .13))
            enemy["timer"] = 1.4 if enemy["id"] == "heavy" else 2.0
        elif enemy["id"] == "bomber":
            _spawn_hazard("mine", _clamp_room(target["pos"] + target["move"] * 60))
            enemy["timer"] = 2.8
            audio.play_sfx("bomber_throw")
        else:
            enemy["timer"] = 1.0
    for request in pending:
        _spawn_enemy(request["id"], request["pos"], false)

func _segment_hit(a: Vector2, b: Vector2, center: Vector2, radius: float) -> bool:
    var ab = b - a
    var fraction = clampf((center - a).dot(ab) / maxf(ab.length_squared(), 0.0001), 0.0, 1.0)
    return (a + ab * fraction).distance_squared_to(center) <= radius * radius

func _update_shots(dt: float) -> void:
    for shot in shots:
        if shot["life"] <= 0:
            continue
        shot["old"] = shot["pos"]
        shot["pos"] += shot["vel"] * dt
        shot["life"] -= dt
        if not ROOM.grow(25).has_point(shot["pos"]):
            shot["life"] = 0
            continue
        if shot["owner"] < 0:
            for p in _active_players():
                if _segment_hit(shot["old"], shot["pos"], p["pos"] + Vector2(0, -12), 20):
                    _hurt_player(p, shot["damage"])
                    shot["life"] = 0
                    break
        else:
            for enemy in enemies:
                if enemy["hp"] <= 0 or shot["hit_ids"].has(enemy["uid"]) or enemy["spawn"] > 0:
                    continue
                if _segment_hit(shot["old"], shot["pos"], enemy["pos"] + Vector2(0, -12), enemy["radius"]):
                    var damage: float = shot["damage"]
                    if enemy["id"] == "shield_guard":
                        var facing = Vector2.from_angle(PI / 2 + DIRS.find(enemy["dir"]) * PI / 4)
                        if facing.dot(-shot["vel"].normalized()) > 0.6:
                            damage *= .25
                            audio.play_sfx("shield_block")
                    _hurt_enemy(enemy, damage, int(shot["owner"]))
                    shot["hit_ids"].append(enemy["uid"])
                    if shot["splash"] > 0:
                        for other in enemies:
                            if other["uid"] != enemy["uid"] and other["hp"] > 0 and other["pos"].distance_to(enemy["pos"]) < shot["splash"]:
                                _hurt_enemy(other, shot["damage"] * .7, int(shot["owner"]))
                        _effect("explosion_medium", enemy["pos"], .75)
                        audio.play_sfx("explosion_medium")
                        shake = 4.0
                    if shot["chain"] > 0:
                        var count = 0
                        for other in enemies:
                            if other["uid"] != enemy["uid"] and other["hp"] > 0 and other["pos"].distance_to(enemy["pos"]) < 150:
                                _hurt_enemy(other, shot["damage"] * .5, int(shot["owner"]))
                                _effect("electric_arcs", other["pos"], .45)
                                count += 1
                                if count >= shot["chain"]:
                                    break
                    if not shot["pierce"]:
                        shot["life"] = 0
                        break
    shots = shots.filter(func(s): return s["life"] > 0)
    enemies = enemies.filter(func(e): return e["hp"] > 0)

func _hurt_enemy(enemy: Dictionary, amount: float, owner: int) -> void:
    if enemy["hp"] <= 0:
        return
    enemy["hp"] -= amount
    enemy["flash"] = .09
    _effect("impact_plasma" if amount > 60 else "impact_enemy", enemy["pos"] + Vector2(0, -15), .25)
    if enemy["hp"] > 0:
        audio.play_sfx("enemy_hit")
        return
    if owner >= 0 and owner < players.size():
        var p: Dictionary = players[owner]
        p["score"] += int(enemy["score"]) * (2 if p["buffs"].has("score_multiplier") else 1)
    _effect("explosion_large" if enemy["boss"] else "explosion_small", enemy["pos"], 1.0 if enemy["boss"] else .55)
    audio.play_sfx("explosion_large" if enemy["boss"] else "enemy_death")
    if enemy["boss"]:
        shake = 7.0
        _add_pickup("extra_life", enemy["pos"])
        audio.announce("big_kill", true)
    elif randf() < enemy_defs[enemy["id"]]["drop_chance"]:
        _add_pickup(pickup_ids[randi() % pickup_ids.size()], enemy["pos"])

func _add_pickup(id: String, point: Vector2) -> void:
    drops.append({"kind": "pickup", "id": id, "pos": point, "life": 22.0})

func _update_drops(dt: float) -> void:
    for item in drops:
        item["life"] -= dt
        for p in _active_players():
            if item["life"] <= 0 or p["pos"].distance_to(item["pos"]) > 31:
                continue
            if item["kind"] == "weapon":
                p["weapon"] = item["id"]
                audio.play_sfx("weapon_pickup")
                _popup(weapons[item["id"]]["display_name"], p["pos"] + Vector2(0, -50), Color(0.2, .85, 1))
            else:
                var id = item["id"]
                match id:
                    "health": p["health"] = minf(100.0, p["health"] + 40.0)
                    "armor": p["armor"] = minf(100.0, p["armor"] + 50.0)
                    "extra_life": p["lives"] = mini(9, p["lives"] + 1)
                    "credits": p["score"] += 5000
                    "prize_box":
                        p["score"] += 10000
                        p["weapon"] = weapon_ids[randi() % weapon_ids.size()]
                        audio.announce("jackpot")
                    _: p["buffs"][id] = 12.0
                audio.play_sfx("extra_life" if id == "extra_life" else "health_pickup" if id == "health" else "credits_pickup")
                _popup(id.replace("_", " ").to_upper(), p["pos"] + Vector2(0, -48), Color(1, .75, .25))
            _effect("pickup_flash", item["pos"], .5)
            item["life"] = 0
            break
    drops = drops.filter(func(item): return item["life"] > 0)

func _spawn_hazard(id: String, point: Vector2) -> void:
    if hazards.size() >= 24:
        return
    hazards.append({"id": id, "pos": _clamp_room(point, 48), "time": -1.4, "life": 9.0 if id != "mine" else 3.2})
    audio.play_sfx("hazard_warning")

func _update_hazards(dt: float) -> void:
    for hazard in hazards:
        var before: float = hazard["time"]
        hazard["time"] += dt
        hazard["life"] -= dt
        if before < 0 and hazard["time"] >= 0:
            audio.play_sfx("electric_floor" if hazard["id"] == "electric_floor" else "laser_charge")
        var active = hazard["time"] >= 0 and fmod(hazard["time"], 4.5) < 1.2
        if not active:
            continue
        for p in _active_players():
            var distance: float = p["pos"].distance_to(hazard["pos"])
            var hit = distance < (64.0 if hazard["id"] == "mine" else 38.0)
            if hazard["id"] == "rotating_laser":
                var ray = Vector2.from_angle(hazard["time"] * 1.9) * 135
                hit = _segment_hit(hazard["pos"] - ray, hazard["pos"] + ray, p["pos"], 18)
            if hit:
                _hurt_player(p, 35 if hazard["id"] == "mine" else 20)
    hazards = hazards.filter(func(h): return h["life"] > 0)

func _effect(id: String, point: Vector2, life: float, angle: float = 0.0) -> void:
    if effects.size() >= 160:
        return
    effects.append({"id": id, "pos": point, "life": life, "total": life, "angle": angle})

func _popup(label: String, point: Vector2, color: Color) -> void:
    popups.append({"text": label, "pos": point, "color": color, "life": 1.7})

func _update_visuals(dt: float) -> void:
    for effect in effects:
        effect["life"] -= dt
    for popup in popups:
        popup["life"] -= dt
        popup["pos"].y -= 23 * dt
    effects = effects.filter(func(e): return e["life"] > 0)
    popups = popups.filter(func(e): return e["life"] > 0)

func _sprite(path: String, point: Vector2, index: int = 0, row: int = 0, pivot: Vector2 = Vector2(-1, -1), color: Color = Color.WHITE, sprite_scale: float = 1.0) -> void:
    var full_path = ART + path
    var metadata: Dictionary = library.record(full_path)
    if metadata.is_empty():
        return
    var tex = library.texture(full_path)
    if tex == null:
        return
    var size = Vector2(metadata["frame_size_px"][0], metadata["frame_size_px"][1])
    if pivot.x < 0:
        pivot = Vector2(metadata["pivot_px"][0], metadata["pivot_px"][1])
    index = clampi(index, 0, int(metadata["columns"]) - 1)
    row = clampi(row, 0, int(metadata["rows"]) - 1)
    draw_texture_rect_region(tex, Rect2(point - pivot * sprite_scale, size * sprite_scale), Rect2(Vector2(index, row) * size, size), color, false, true)

func _actor(enemy: Dictionary) -> void:
    var action: String
    var category = "bosses" if enemy["boss"] else "enemies"
    var row = 0 if enemy["boss"] else DIRS.find(enemy["dir"])
    if enemy["boss"]:
        action = "attack" if enemy["attack_flash"] > 0 else "walk"
    else:
        action = enemy_defs[enemy["id"]]["move_animation"]
    var path = "sprites/" + category + "/" + enemy["id"] + "_" + action + ".png"
    var meta = library.record(ART + path)
    if meta.is_empty():
        return
    var frame = int(enemy["anim_time"] * 10) % int(meta["columns"])
    var tint = Color(1.8, 1.8, 1.8, 1) if enemy["flash"] > 0 else Color.WHITE
    if enemy["spawn"] > 0:
        tint.a = 0.45
    _sprite("sprites/effects/ground_shadow.png", enemy["pos"] + Vector2(0, 9))
    _sprite(path, enemy["pos"], frame, row, Vector2(-1, -1), tint)

func _draw() -> void:
    if players.is_empty() or font == null:
        return
    var tile = library.texture(ART + "tilesets/arena/arena_tiles.png")
    if tile != null:
        for y in range(14):
            for x in range(12):
                var index = 10 if y == 0 else 11 if y == 13 else 12 if x == 0 else 13 if x == 11 else 2 if (x + y) % 4 == 0 else 0
                draw_texture_rect_region(tile, Rect2(x * 64, 128 + y * 64, 64, 64), Rect2((index % 8) * 64, int(index / 8) * 64, 64, 64))
    var door_state = "warning" if phase == "warning" else "open" if phase == "clear" else "closed"
    for point in [Vector2(384, 150), Vector2(384, 980), Vector2(38, 555), Vector2(730, 555)]:
        _sprite("tilesets/arena/door_" + door_state + ".png", point, int(game_time * 8) % (4 if door_state == "warning" else 1))
    for hazard in hazards:
        var age: float = hazard["time"]
        var state = "warning" if age < 0 else "active" if fmod(age, 4.5) < 1.2 else "cooldown"
        _sprite("sprites/hazards/" + hazard["id"] + "_" + state + ".png", hazard["pos"], int(game_time * 8) % 4)
        if state == "warning":
            draw_arc(hazard["pos"], 45, 0, TAU, 28, Color(1, .65, .2, .65), 2)
        if state == "active" and hazard["id"] == "rotating_laser":
            var ray = Vector2.from_angle(age * 1.9) * 135
            draw_line(hazard["pos"] - ray, hazard["pos"] + ray, Color(.95, .2, .7), 5)
            draw_line(hazard["pos"] - ray, hazard["pos"] + ray, Color.WHITE, 1)
    for drop in drops:
        if drop["kind"] == "weapon":
            _sprite("sprites/pickups/weapon_" + drop["id"] + ".png", drop["pos"])
        else:
            _sprite("sprites/pickups/" + drop["id"] + ".png", drop["pos"], int(game_time * 10) % 8)
    var sorted = enemies.duplicate()
    sorted.sort_custom(func(a, b): return a["pos"].y < b["pos"].y)
    for enemy in sorted:
        _actor(enemy)
    for p in players:
        if p["id"] == 1 and not p2_enabled:
            continue
        if p["lives"] <= 0:
            continue
        var dead = p["respawn"] > 0
        var action = "death" if dead else "run" if p["move"].length() > .05 else "idle"
        var frames = 8 if dead else 6 if action == "run" else 4
        var frame = mini(7, int((2.0 - p["respawn"]) * 10)) if dead else int(p["anim_time"] * (12 if action == "run" else 6)) % frames
        var tint = Color.WHITE
        if p["invuln"] > 0 and int(game_time * 15) % 2 == 0:
            tint.a = .45
        _sprite("sprites/effects/ground_shadow.png", p["pos"] + Vector2(0, 9))
        _sprite("sprites/players/" + p["name"] + "_" + action + ".png", p["pos"], frame, DIRS.find(p["dir"]), Vector2(-1, -1), tint)
        if dead:
            continue
        var origin: Vector2 = p["pos"] + Vector2(0, -18)
        if p["weapon"] == "orbit_drone":
            origin += Vector2.from_angle(game_time * 3) * 42
        draw_set_transform(origin, p["aim"].angle(), Vector2.ONE)
        _sprite("sprites/weapons/" + p["weapon"] + ".png", Vector2.ZERO, int(game_time * 10) % 4, 0, Vector2(24, 32), tint)
        draw_set_transform(Vector2.ZERO)
        if p["buffs"].has("invulnerability"):
            draw_arc(p["pos"] + Vector2(0, -12), 32, 0, TAU, 32, Color(.8, .65, 1, .6), 2)
        if p["id"] == 1:
            _sprite("ui/hud/crosshair_p2.png", p["pos"] + p["aim"] * 115)
    for shot in shots:
        draw_set_transform(shot["pos"], shot["vel"].angle(), Vector2.ONE)
        _sprite("sprites/projectiles/" + shot["kind"] + ".png", Vector2.ZERO, int(game_time * 16) % 4)
        draw_set_transform(Vector2.ZERO)
    for effect in effects:
        var path = "sprites/effects/" + effect["id"] + ".png"
        var meta = library.record(ART + path)
        if meta.is_empty():
            continue
        var frame = mini(int(meta["columns"]) - 1, int((1 - effect["life"] / effect["total"]) * meta["columns"]))
        draw_set_transform(effect["pos"], effect["angle"], Vector2.ONE)
        _sprite(path, Vector2.ZERO, frame)
        draw_set_transform(Vector2.ZERO)
    for popup in popups:
        var tint: Color = popup["color"]
        tint.a = minf(1.0, popup["life"] * 2)
        _label(popup["text"], popup["pos"], 21, tint, true)
    _sprite("ui/hud/crosshair_p1.png", get_global_mouse_position())
    _hud()

func _label(label: String, point: Vector2, font_size: int = 20, color: Color = Color.WHITE, centered: bool = false) -> void:
    var position = point
    if centered:
        position.x -= font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / 2
    draw_string(font, position + Vector2(2, 2), label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0, 0, 0, color.a))
    draw_string(font, position, label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _hud() -> void:
    draw_rect(Rect2(0, 0, 768, 128), Color(.018, .025, .065, .98))
    for i in range(2):
        var p: Dictionary = players[i]
        var x = 12 if i == 0 else 396
        var color = Color(.1, .8, 1) if i == 0 else Color(1, .76, .22)
        _label(("P1 VOLT" if i == 0 else "P2 NOVA") + (" [OFF]" if i == 1 and not p2_enabled else ""), Vector2(x, 24), 18, color)
        _label("%08d" % p["score"], Vector2(x + 200, 24), 17)
        draw_rect(Rect2(x, 34, 245, 12), Color(.09, .14, .21))
        draw_rect(Rect2(x, 34, 245 * maxf(0, p["health"]) / 100, 12), Color(.25, .9, .5))
        if p["armor"] > 0:
            draw_rect(Rect2(x, 48, 245 * p["armor"] / 100, 4), Color(.1, .6, 1))
        _label("LIVES %d" % p["lives"], Vector2(x, 70), 14, color)
        _label(weapons[p["weapon"]]["display_name"], Vector2(x, 92), 14)
    _label("ARENA BRAWL", Vector2(384, 70), 22, Color(.5, .8, .95), true)
    _label("WAVE %02d/20" % (wave_index + 1), Vector2(384, 104), 18, Color(1, .35, .85), true)
    for enemy in enemies:
        if enemy["boss"]:
            draw_rect(Rect2(139, 132, 490, 15), Color(.12, .09, .16))
            draw_rect(Rect2(141, 134, 486 * maxf(0, enemy["hp"]) / enemy["max_hp"], 11), Color(.95, .2, .6))
            _label(boss_defs[enemy["id"]]["display_name"], Vector2(384, 166), 18, Color.WHITE, true)
            break
    if phase == "warning":
        _label("GET READY - WAVE %02d" % (wave_index + 1), Vector2(384, 500), 30, Color(1, .76, .25), true)
    if show_help:
        draw_rect(Rect2(12, 950, 744, 62), Color(.02, .04, .08, .94))
        _label("LEFT STICK MOVE  RIGHT STICK AIM  A/X/TRIGGER FIRE", Vector2(28, 975), 15)
        _label("START PAUSE  F1 HELP  R RESTART  ESC EXIT", Vector2(28, 998), 14, Color(.55, .76, .87))
    if debug_info:
        _label("FPS %d | ENEMIES %d | SHOTS %d" % [Engine.get_frames_per_second(), enemies.size(), shots.size()], Vector2(16, 1015), 13, Color(1, .85, .3))
    if demo_paused or game_over or victory:
        draw_rect(Rect2(0, 128, 768, 896), Color(.015, .025, .05, .86))
        _label("CHAMPIONS!" if victory else "GAME OVER" if game_over else "PAUSED", Vector2(384, 450), 52, Color(1, .76, .22), true)
        _label("START: RESUME    R: RESTART    ESC: EXIT", Vector2(384, 515), 20, Color.WHITE, true)

func _make_crt() -> void:
    crt_layer = CanvasLayer.new()
    crt_layer.layer = 8
    crt_layer.visible = false
    add_child(crt_layer)
    crt_rect = ColorRect.new()
    crt_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    crt_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var material = ShaderMaterial.new()
    material.shader = load(BASE + "shaders/crt.gdshader")
    crt_rect.material = material
    crt_layer.add_child(crt_rect)

func _exit_tree() -> void:
    if is_instance_valid(audio):
        audio.stop_all()
