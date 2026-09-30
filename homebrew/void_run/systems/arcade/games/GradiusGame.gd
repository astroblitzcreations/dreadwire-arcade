class_name ArcadeGradiusGame
extends Control

signal finished(payout: int, summary: String)

const TITLE_MUSIC := preload("res://assets/arcade_district/void_run/audio/starfighter_assault.mp3")
const LEVEL_MUSIC := preload("res://assets/arcade_district/void_run/audio/galactic_defender.mp3")
const BOSS_MUSIC := preload("res://assets/arcade_district/void_run/audio/fortress_protocol.mp3")
const PLAYER_ART := preload("res://assets/arcade_district/void_run/rendered/player_ship.png")
const ENEMY_ART := preload("res://assets/arcade_district/void_run/rendered/enemy_fighters.png")
const ELITE_ART := preload("res://assets/arcade_district/void_run/rendered/elite_enemies.png")
const BOSS_ART := preload("res://assets/arcade_district/void_run/rendered/bosses.png")
const PICKUP_ART := preload("res://assets/arcade_district/void_run/rendered/pickups.png")
const EXPLOSION_ART := preload("res://assets/arcade_district/void_run/rendered/explosions_sequence.png")
const WEAPON_ART := preload("res://assets/arcade_district/void_run/rendered/weapons.png")
const SOUND_BANK_SCRIPT := preload("res://systems/arcade/audio/VoidRunSoundBank.gd")
const CUSTOM_EXPLOSION_SOUND := preload("res://audio/void_run/custom/freesound_community-explosion-6055.mp3")
const CUSTOM_POWERUP_SOUND := preload("res://audio/void_run/custom/edr-power-up-01a-484722.mp3")
const LEVEL_TIME := 48.0
const SAVE_PATH := "user://void_run_save.cfg"

var ship := Vector2(180, 420)
var enemies: Array[Dictionary] = []
var shots: Array[Dictionary] = []
var enemy_shots: Array[Dictionary] = []
var pickups: Array[Dictionary] = []
var effects: Array[Dictionary] = []
var score := 0
var coins := 0
var lives := 3
var shield := 0
var power := 1
var level_time := 0.0
var current_level := 1
var high_score := 0
var spawn_clock := 0.0
var shot_clock := 0.0
var missile_clock := 0.0
var invulnerable := 0.0
var started := false
var ended := false
var boss_spawned := false
var title: Label
var title_menu: PanelContainer
var continue_entry: LineEdit
var menu_message: Label
var music: AudioStreamPlayer
var stars_far: Array[Vector2] = []
var stars_mid: Array[Vector2] = []
var stars_near: Array[Vector2] = []
var transition_boost := 0.0
var respawn_timer := 0.0
var travel_speed := 0.3
var space_objects: Array[Dictionary] = []
var next_extra_life := 5000
var screen_flash := 0.0
var sound_bank: Node
var boost_energy := 100.0
var boosting := false
var was_boosting := false
var boost_depleted := false
var boost_bar: ProgressBar
var boost_label: Label
var shield_visual: ColorRect
var afterburner_visual: ColorRect
var paused := false
var pause_panel: PanelContainer
var muzzle: Marker2D
var bg_rect: ColorRect
var bg_material: ShaderMaterial
var boss_warning_overlay: ColorRect
var boss_warning_material: ShaderMaterial
var boss_warning_label: Label
var boss_warning_timer := 0.0
var boss_sequence_state := "idle"
var boss_phase_clock := 0.0

func _ready() -> void:
	for index in 70: stars_far.append(Vector2(randf_range(0,1900),randf_range(70,1000)))
	for index in 42: stars_mid.append(Vector2(randf_range(0,1900),randf_range(70,1000)))
	for index in 22: stars_near.append(Vector2(randf_range(0,1900),randf_range(70,1000)))
	space_objects=[{"p":Vector2(1450,250),"r":72.0,"speed":7.0,"c":Color("#25426d")},{"p":Vector2(2350,690),"r":118.0,"speed":11.0,"c":Color("#3e2258")},{"p":Vector2(3300,180),"r":42.0,"speed":15.0,"c":Color("#6b4b58")}]
	title = Label.new(); title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE, Control.PRESET_MODE_MINSIZE, 16); title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; title.add_theme_font_size_override("font_size", 22); title.add_theme_color_override("font_color", Color("#66efff")); title.mouse_filter = Control.MOUSE_FILTER_IGNORE; add_child(title)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_space_background()
	_load_high_score()
	_build_title_menu()
	music = AudioStreamPlayer.new();music.volume_db=6;add_child(music);_play_music(TITLE_MUSIC)
	sound_bank=SOUND_BANK_SCRIPT.new();sound_bank.name="VoidRunSoundBank";add_child(sound_bank)
	muzzle=Marker2D.new();muzzle.name="Muzzle";add_child(muzzle)
	_build_flight_hud();_build_shield_shader();_build_afterburner_shader();_build_boss_warning();_build_pause_menu()
	queue_redraw()

func _build_flight_hud()->void:
	boost_label=Label.new();boost_label.text="AFTERBURNER";boost_label.position=Vector2(34,82);boost_label.add_theme_font_size_override("font_size",12);boost_label.add_theme_color_override("font_color",Color("#65eaff"));boost_label.visible=false;add_child(boost_label)
	boost_bar=ProgressBar.new();boost_bar.position=Vector2(34,102);boost_bar.size=Vector2(220,13);boost_bar.min_value=0;boost_bar.max_value=100;boost_bar.value=100;boost_bar.show_percentage=false;boost_bar.visible=false;var boost_bg:=StyleBoxFlat.new();boost_bg.bg_color=Color("#07121d");boost_bg.border_color=Color("#22798a");boost_bg.set_border_width_all(1);boost_bar.add_theme_stylebox_override("background",boost_bg);var boost_fill:=StyleBoxFlat.new();boost_fill.bg_color=Color("#41e9ff");boost_fill.corner_radius_top_left=4;boost_fill.corner_radius_top_right=4;boost_fill.corner_radius_bottom_left=4;boost_fill.corner_radius_bottom_right=4;boost_bar.add_theme_stylebox_override("fill",boost_fill);add_child(boost_bar)

func _build_space_background()->void:
	bg_rect=ColorRect.new();bg_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);bg_rect.mouse_filter=Control.MOUSE_FILTER_IGNORE;bg_rect.show_behind_parent=true
	bg_material=ShaderMaterial.new();bg_material.shader=preload("res://assets/arcade_district/void_run/shaders/trippy_space_background.gdshader");bg_rect.material=bg_material;add_child(bg_rect);move_child(bg_rect,0)

func _build_boss_warning()->void:
	boss_warning_overlay=ColorRect.new();boss_warning_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);boss_warning_overlay.mouse_filter=Control.MOUSE_FILTER_IGNORE;boss_warning_overlay.visible=false;boss_warning_overlay.z_index=80
	boss_warning_material=ShaderMaterial.new();boss_warning_material.shader=preload("res://assets/arcade_district/void_run/shaders/boss_warning.gdshader");boss_warning_overlay.material=boss_warning_material;add_child(boss_warning_overlay)
	boss_warning_label=Label.new();boss_warning_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER,Control.PRESET_MODE_MINSIZE);boss_warning_label.position=Vector2(-370,-82);boss_warning_label.custom_minimum_size=Vector2(740,164);boss_warning_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;boss_warning_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;boss_warning_label.text="⚠  WARNING  ⚠\nMASSIVE HOSTILE SIGNAL";boss_warning_label.add_theme_font_size_override("font_size",34);boss_warning_label.add_theme_color_override("font_color",Color("#fff0e8"));boss_warning_label.add_theme_color_override("font_shadow_color",Color("#ff002f"));boss_warning_label.add_theme_constant_override("shadow_offset_x",4);boss_warning_label.add_theme_constant_override("shadow_offset_y",4);boss_warning_label.mouse_filter=Control.MOUSE_FILTER_IGNORE;boss_warning_label.visible=false;boss_warning_label.z_index=81;add_child(boss_warning_label)

func _build_shield_shader()->void:
	shield_visual=ColorRect.new();shield_visual.size=Vector2(150,124);shield_visual.mouse_filter=Control.MOUSE_FILTER_IGNORE;shield_visual.visible=false
	var shader:=Shader.new();shader.code="shader_type canvas_item; render_mode blend_add; uniform vec4 shield_color : source_color = vec4(0.0,0.95,1.0,1.0); uniform float intensity : hint_range(0.0,5.0) = 1.8; uniform float rim_thickness : hint_range(0.1,1.0) = 0.35; void fragment(){ vec2 center_uv=UV-vec2(0.5); float dist=length(center_uv)*2.0; float rim=smoothstep(1.0-rim_thickness,1.0,dist); float wave=sin(dist*20.0-TIME*6.0)*0.5+0.5; float mask=step(dist,1.0); vec3 final_rgb=shield_color.rgb*(rim*intensity+wave*0.3); float final_a=(rim*0.8+wave*0.1)*mask*shield_color.a; COLOR=vec4(final_rgb,final_a); }"
	var material:=ShaderMaterial.new();material.shader=shader;shield_visual.material=material;add_child(shield_visual)

func _build_afterburner_shader()->void:
	afterburner_visual=ColorRect.new();afterburner_visual.size=Vector2(100,54);afterburner_visual.mouse_filter=Control.MOUSE_FILTER_IGNORE;afterburner_visual.visible=false
	var shader:=Shader.new();shader.code="shader_type canvas_item; render_mode blend_add; uniform vec4 hot : source_color=vec4(1.0,.86,.28,1.0); uniform vec4 cool : source_color=vec4(.05,.78,1.0,1.0); void fragment(){ vec2 p=UV; float taper=mix(.08,.46,p.x); float body=smoothstep(taper,taper-.12,abs(p.y-.5)); float flicker=.76+.24*sin(TIME*31.0+p.x*38.0+sin(p.y*24.0)); float flame=body*smoothstep(0.0,.18,p.x)*smoothstep(1.0,.08,p.x)*flicker; float core=body*smoothstep(.66,.95,p.x); vec3 col=mix(cool.rgb,hot.rgb,core); COLOR=vec4(col,flame*(.55+core*.45)); }"
	var material:=ShaderMaterial.new();material.shader=shader;afterburner_visual.material=material;add_child(afterburner_visual);move_child(afterburner_visual,0)

func _build_pause_menu()->void:
	pause_panel=PanelContainer.new();pause_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER,Control.PRESET_MODE_MINSIZE);pause_panel.position=Vector2(-330,-310);pause_panel.custom_minimum_size=Vector2(660,620);pause_panel.visible=false;pause_panel.mouse_filter=Control.MOUSE_FILTER_STOP;pause_panel.z_index=100;add_child(pause_panel)
	var style:=StyleBoxFlat.new();style.bg_color=Color(0.01,0.02,0.055,.98);style.border_color=Color("#48e5ff");style.set_border_width_all(3);style.corner_radius_top_left=18;style.corner_radius_top_right=18;style.corner_radius_bottom_left=18;style.corner_radius_bottom_right=18;style.shadow_color=Color(0,0,0,.85);style.shadow_size=24;pause_panel.add_theme_stylebox_override("panel",style)
	var box:=VBoxContainer.new();box.alignment=BoxContainer.ALIGNMENT_CENTER;box.add_theme_constant_override("separation",14);pause_panel.add_child(box)
	var heading:=Label.new();heading.text="VOID RUN PAUSED";heading.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;heading.add_theme_font_size_override("font_size",38);heading.add_theme_color_override("font_color",Color("#69edff"));box.add_child(heading)
	var warning:=Label.new();warning.text="EXITING ENDS THIS RUN\nNO CASH PAYOUT AND NO ADMISSION REFUND";warning.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;warning.add_theme_font_size_override("font_size",16);warning.add_theme_color_override("font_color",Color("#ff8098"));box.add_child(warning)
	var resume:=Button.new();resume.text="RESUME GAME";resume.custom_minimum_size=Vector2(420,52);resume.pressed.connect(_resume_game);box.add_child(resume)
	var music_text:=Label.new();music_text.text="MUSIC VOLUME";music_text.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;box.add_child(music_text)
	var music_slider:=HSlider.new();music_slider.min_value=-30;music_slider.max_value=12;music_slider.value=6;music_slider.custom_minimum_size=Vector2(420,32);music_slider.value_changed.connect(_set_music_volume);box.add_child(music_slider)
	var sound_text:=Label.new();sound_text.text="SOUND EFFECTS VOLUME";sound_text.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;box.add_child(sound_text)
	var sound_slider:=HSlider.new();sound_slider.min_value=-30;sound_slider.max_value=12;sound_slider.value=6;sound_slider.custom_minimum_size=Vector2(420,32);sound_slider.value_changed.connect(_set_sound_volume);box.add_child(sound_slider)
	var controls_title:=Label.new();controls_title.text="CONTROLS";controls_title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;controls_title.add_theme_font_size_override("font_size",20);controls_title.add_theme_color_override("font_color",Color("#ffd467"));box.add_child(controls_title)
	var controls:=Label.new();controls.text="MOVE   Arrow Keys or configured movement controls\nFIRE   Space, Fire binding, or Left Mouse\nAFTERBURNER   Shift, Ctrl, Run, or Sprint binding\nPAUSE   Escape";controls.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;controls.add_theme_font_size_override("font_size",15);controls.add_theme_color_override("font_color",Color("#b8cbd8"));box.add_child(controls)
	var exit:=Button.new();exit.text="EXIT GAME — FORFEIT RUN";exit.custom_minimum_size=Vector2(420,52);exit.add_theme_color_override("font_color",Color("#ff8098"));exit.pressed.connect(_forfeit_run);box.add_child(exit)

func request_pause_menu()->void:
	if not started or ended:return
	if paused:_resume_game()
	else:
		paused=true;pause_panel.visible=true;music.stream_paused=true;sound_bank.stop_loop("engine",.08);sound_bank.play_event("ui_pause")

func _resume_game()->void:
	paused=false;pause_panel.visible=false;music.stream_paused=false;sound_bank.play_event("ui_resume");sound_bank.start_loop("engine_boost_loop" if boosting else "engine_idle_loop","engine",.12)

func _forfeit_run()->void:
	if ended:return
	ended=true;paused=false;music.stop();sound_bank.stop_all();finished.emit(0,"RUN FORFEITED\nNO CASH PAYOUT\nADMISSION COST NOT REFUNDED");queue_free()

func _set_sound_volume(value:float)->void:
	var bus:=AudioServer.get_bus_index("VoidRun")
	if bus>=0:AudioServer.set_bus_volume_db(bus,value)

func _unhandled_input(event: InputEvent) -> void:
	# The Arcade1Up Start control is physical joystick button 7.  Handle it
	# directly because Godot's stock ui_accept mapping only covers button 0.
	if not started and event.is_action_pressed("cabinet_start"):
		_start_run(1);get_viewport().set_input_as_handled();return
	if not started and event is InputEventKey and event.pressed and (event.physical_keycode == KEY_ENTER or event.keycode == KEY_ENTER):
		_start_run(1);get_viewport().set_input_as_handled();return
	if event.is_action_pressed("ui_cancel"):
		request_pause_menu();get_viewport().set_input_as_handled();return
	if started and (event.is_action_pressed("ui_accept") or event.is_action_pressed("fire") or (event is InputEventKey and event.pressed and event.physical_keycode == KEY_SPACE)): get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right") or event.is_action_pressed("move_up") or event.is_action_pressed("move_down") or event.is_action_pressed("move_left") or event.is_action_pressed("move_right"): get_viewport().set_input_as_handled()

func _movement() -> Vector2:
	var configured := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var arrows := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	return configured if configured.length_squared() >= arrows.length_squared() else arrows

func _build_title_menu() -> void:
	title_menu = PanelContainer.new(); title_menu.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE); title_menu.position = Vector2(-310,-300); title_menu.custom_minimum_size = Vector2(620,600); add_child(title_menu)
	var style := StyleBoxFlat.new(); style.bg_color = Color(0.015,0.025,0.08,.94); style.border_color = Color("#38dffc"); style.set_border_width_all(3); style.corner_radius_top_left=18;style.corner_radius_top_right=18;style.corner_radius_bottom_left=18;style.corner_radius_bottom_right=18;style.shadow_color=Color(0,0,0,.8);style.shadow_size=20;title_menu.add_theme_stylebox_override("panel",style)
	var box:=VBoxContainer.new();box.alignment=BoxContainer.ALIGNMENT_CENTER;box.add_theme_constant_override("separation",12);title_menu.add_child(box)
	var logo:=Label.new();logo.text="VOID RUN";logo.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;logo.add_theme_font_size_override("font_size",54);logo.add_theme_color_override("font_color",Color("#55eaff"));box.add_child(logo)
	var subtitle:=Label.new();subtitle.text="STARFIGHTER ASSAULT";subtitle.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;subtitle.add_theme_font_size_override("font_size",18);subtitle.add_theme_color_override("font_color",Color("#ff58cf"));box.add_child(subtitle)
	var record:=Label.new();record.text="HIGH SCORE  %08d"%high_score;record.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;record.add_theme_font_size_override("font_size",25);record.add_theme_color_override("font_color",Color("#ffd35c"));box.add_child(record)
	var start:=Button.new();start.text="START GAME";start.custom_minimum_size=Vector2(360,52);start.pressed.connect(_start_run.bind(1));box.add_child(start)
	continue_entry=LineEdit.new();continue_entry.placeholder_text="ENTER 10-DIGIT CONTINUE CODE";continue_entry.max_length=10;continue_entry.custom_minimum_size=Vector2(360,48);continue_entry.alignment=HORIZONTAL_ALIGNMENT_CENTER;box.add_child(continue_entry)
	var keypad:=GridContainer.new();keypad.columns=5;keypad.size_flags_horizontal=Control.SIZE_SHRINK_CENTER;box.add_child(keypad)
	for digit in 10:
		var key:=Button.new();key.text=str(digit);key.custom_minimum_size=Vector2(62,42);key.pressed.connect(_append_code_digit.bind(digit));keypad.add_child(key)
	var edit_row:=HBoxContainer.new();edit_row.alignment=BoxContainer.ALIGNMENT_CENTER;box.add_child(edit_row)
	var delete_key:=Button.new();delete_key.text="DELETE";delete_key.custom_minimum_size=Vector2(174,40);delete_key.pressed.connect(_delete_code_digit);edit_row.add_child(delete_key)
	var clear_key:=Button.new();clear_key.text="CLEAR";clear_key.custom_minimum_size=Vector2(174,40);clear_key.pressed.connect(func():continue_entry.text="");edit_row.add_child(clear_key)
	var continue_button:=Button.new();continue_button.text="CONTINUE FROM CODE";continue_button.custom_minimum_size=Vector2(360,48);continue_button.pressed.connect(_continue_from_code);box.add_child(continue_button)
	var options_title:=Label.new();options_title.text="OPTIONS  •  MUSIC VOLUME";options_title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;options_title.add_theme_color_override("font_color",Color("#55eaff"));box.add_child(options_title)
	var volume:=HSlider.new();volume.min_value=-30;volume.max_value=12;volume.value=6;volume.custom_minimum_size=Vector2(360,32);volume.value_changed.connect(_set_music_volume);box.add_child(volume)
	var controls:=Label.new();controls.text="MOVE: ARROWS OR YOUR CONFIGURED MOVEMENT KEYS    FIRE: SPACE OR FIRE BINDING";controls.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;controls.add_theme_font_size_override("font_size",12);controls.add_theme_color_override("font_color",Color("#9ebbc9"));box.add_child(controls)
	menu_message=Label.new();menu_message.text="BOSSES APPEAR EVERY 5 LEVELS";menu_message.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;menu_message.add_theme_color_override("font_color",Color("#9ebbc9"));box.add_child(menu_message)

func _append_code_digit(digit:int)->void:
	if continue_entry.text.length()<10:continue_entry.text+=str(digit)

func _delete_code_digit()->void:
	continue_entry.text=continue_entry.text.left(maxi(0,continue_entry.text.length()-1))

func _continue_from_code()->void:
	var level:=_decode_continue_code(continue_entry.text)
	if level<1:menu_message.text="INVALID CODE • CHECK ALL 10 DIGITS";menu_message.add_theme_color_override("font_color",Color("#ff718e"));return
	_start_run(level)

func _start_run(level:int)->void:
	current_level=maxi(1,level);level_time=0;score=0;coins=0;lives=3;next_extra_life=5000;shield=0;power=1;boost_energy=100;boosting=false;boost_depleted=false;respawn_timer=0;travel_speed=.3;enemies.clear();shots.clear();enemy_shots.clear();pickups.clear();effects.clear();boss_spawned=false;boss_sequence_state="idle";boss_warning_timer=0;boss_phase_clock=0;ended=false;started=true;title_menu.visible=false;boost_bar.visible=true;boost_label.visible=true;sound_bank.play_event("ui_game_start");sound_bank.play_event("engine_power_up");sound_bank.start_loop("engine_idle_loop","engine",.15);_play_music(BOSS_MUSIC if current_level%5==0 else LEVEL_MUSIC)

func _continue_code(level:int)->String:
	var first:="%04d%04d"%[level%10000,(level*7919+2609)%10000]
	var checksum:=0
	for character in first:checksum+=int(character)
	return first+"%02d"%(checksum%100)

func _decode_continue_code(code:String)->int:
	if code.length()!=10 or not code.is_valid_int():return -1
	var level:=int(code.left(4));return level if level>0 and _continue_code(level)==code else -1

func _complete_level()->void:
	var leaving_boss:=current_level%5==0
	# Preserve everything still in flight so clearing a stage never makes surviving
	# enemies or their projectiles visibly pop out of existence.
	current_level+=1;level_time=0;boss_spawned=false;boss_sequence_state="idle";boss_warning_timer=0;boss_phase_clock=0;score+=60+current_level*8;transition_boost=3.4;travel_speed=.42
	sound_bank.play_event("ui_stage_clear");sound_bank.play_event("warp_in")
	if current_level%5==0:_play_music(BOSS_MUSIC)
	elif leaving_boss:_play_music(LEVEL_MUSIC)
	menu_message.text="CONTINUE CODE  "+_continue_code(current_level)

func _play_music(stream:AudioStream)->void:
	if not music:return
	music.stream=stream
	if stream is AudioStreamMP3:(stream as AudioStreamMP3).loop=true
	music.play()

func _set_music_volume(value:float)->void:
	if music:music.volume_db=value

func _load_high_score()->void:
	var config:=ConfigFile.new()
	if config.load(SAVE_PATH)==OK:high_score=int(config.get_value("scores","high_score",0))

func _save_high_score()->void:
	if score<=high_score:return
	high_score=score;var config:=ConfigFile.new();config.set_value("scores","high_score",high_score);config.save(SAVE_PATH)

func _update_starfield(delta:float)->void:
	transition_boost=maxf(0,transition_boost-delta)
	travel_speed=move_toward(travel_speed,1.0+minf(current_level*.055,.7),delta*.035)
	var boost:=(2.8 if current_level%5==0 else (2.2 if transition_boost>0 else 1.0))*travel_speed*(1.85 if boosting else 1.0)
	_scroll_star_layer(stars_far,18.0*boost,delta)
	_scroll_star_layer(stars_mid,55.0*boost,delta)
	_scroll_star_layer(stars_near,145.0*boost,delta)
	for object in space_objects:
		object.p.x-=object.speed*boost*delta
		if object.p.x < -object.r*2.0:object.p.x=size.x+randf_range(650,1500);object.p.y=randf_range(130,size.y-100)

func _scroll_star_layer(layer:Array[Vector2],speed:float,delta:float)->void:
	for index in layer.size():
		layer[index].x-=speed*delta
		if layer[index].x < -20:layer[index]=Vector2(size.x+randf_range(0,80),randf_range(70,size.y-30))

func _process(delta: float) -> void:
	if ended: return
	if bg_material:
		bg_material.set_shader_parameter("warp_intensity",clampf(transition_boost/3.4,0.0,1.0))
		bg_material.set_shader_parameter("black_hole_tier",float(current_level/5) if current_level%5==0 else 0.0)
		bg_material.set_shader_parameter("level_energy",clampf(float(current_level-1)/24.0,0.0,1.0))
	if not started: title.text = ""; _update_starfield(delta); queue_redraw(); return
	if paused:queue_redraw();return
	var run_held:=Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CTRL) or (InputMap.has_action("run") and Input.is_action_pressed("run")) or (InputMap.has_action("sprint") and Input.is_action_pressed("sprint"))
	if not run_held:boost_depleted=false
	boosting=run_held and not boost_depleted and boost_energy>0.5 and respawn_timer<=0
	if boosting:
		boost_energy=maxf(0,boost_energy-31.0*delta)
		if boost_energy<=0.5:boost_energy=0;boost_depleted=true;boosting=false
	else:boost_energy=minf(100,boost_energy+17.0*delta)
	if boosting!=was_boosting:
		sound_bank.play_event("boost_start" if boosting else "boost_stop");sound_bank.start_loop("engine_boost_loop" if boosting else "engine_idle_loop","engine",.14);was_boosting=boosting
	boost_bar.value=boost_energy
	if respawn_timer>0:
		respawn_timer=maxf(0,respawn_timer-delta)
		if respawn_timer==0:ship=Vector2(180,size.y*.5);invulnerable=2.0;sound_bank.play_event("ui_respawn")
	else:
		ship += _movement() * (650.0 if boosting else 420.0) * delta; ship.x = clampf(ship.x, 75, size.x - 90); ship.y = clampf(ship.y, 125, size.y - 75)
	# The rendered ship occupies the lower portion of its atlas cell. These sockets
	# are aligned to the visible nose and engine, not the cell's empty center.
	muzzle.position=ship+Vector2(66,30)
	shot_clock -= delta;missile_clock-=delta; invulnerable = maxf(0, invulnerable - delta); spawn_clock -= delta
	if respawn_timer<=0 and (Input.is_action_pressed("ui_accept") or Input.is_action_pressed("fire") or Input.is_key_pressed(KEY_SPACE) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and shot_clock <= 0: _fire()
	if current_level%5==0:
		_update_boss_sequence(delta)
	elif spawn_clock<=0:
		_spawn_enemy();spawn_clock=randf_range(.38,.78)
	_update_shots(delta); _update_enemy_shots(delta); _update_enemies(delta); _update_pickups(delta); _update_effects(delta); _update_starfield(delta); screen_flash=maxf(0,screen_flash-delta)
	while score >= next_extra_life:
		lives += 1; next_extra_life += 5000; _spawn_effect(ship,"life");sound_bank.play_event("pickup_life")
	level_time += delta
	title.text = "VOID RUN  •  LEVEL %02d  •  SCORE %06d  •  COINS %02d  •  LIVES %d  •  POWER %d" % [current_level, score, coins, lives, power]
	shield_visual.visible=shield>0 and respawn_timer<=0;shield_visual.position=ship+Vector2(4,30)-shield_visual.size*.5
	afterburner_visual.visible=boosting and respawn_timer<=0;afterburner_visual.position=ship+Vector2(-148,3)
	if current_level % 5 != 0 and level_time >= LEVEL_TIME: _complete_level()
	queue_redraw()

func _fire() -> void:
	shot_clock = maxf(.13,.20-power*.012)
	var muzzle_position:=muzzle.position
	shots.append({"p":muzzle_position,"v":Vector2.RIGHT*1050.0,"damage":1.0,"type":"pulse"})
	sound_bank.play_event("laser_powered" if power>=3 else "laser_light")
	if power >= 2:
		for angle_degrees in [-8.0,8.0,-16.0,16.0]:
			var angle:float=deg_to_rad(float(angle_degrees));shots.append({"p":muzzle_position,"v":Vector2.RIGHT.rotated(angle)*1000.0,"damage":.28,"type":"spread"})
		sound_bank.play_event("spread_shot")
	if power >= 3:shots.append({"p":muzzle_position,"v":Vector2(1150,0),"damage":.65,"type":"laser"})
	if power >= 4 and missile_clock<=0:
		shots.append({"p":ship+Vector2(28,18),"v":Vector2(520,80),"damage":1.5,"type":"missile"});missile_clock=.8;sound_bank.play_event("missile_launch")
	if power >= 5:shots.append({"p":muzzle_position,"v":Vector2(1200,0),"damage":.7,"type":"beam"})

func _spawn_enemy() -> void:
	var kind := randi_range(0,4)
	var roll:=randf();var pattern:=0
	if roll>.97:pattern=3
	elif roll>.88:pattern=2
	elif roll>.67:pattern=1
	enemies.append({"p":Vector2(size.x + 95,randf_range(145,size.y-85)), "v":randf_range(205,355)+current_level*3, "hp":1+kind/2, "kind":kind, "phase":randf_range(0,TAU), "fire":randf_range(1.0,2.8), "pattern":pattern,"burst_left":0,"burst_delay":0.0,"boss":false})

func _spawn_boss() -> void:
	var boss_health:=220+current_level*35
	boss_spawned=true;boss_sequence_state="entering";boss_phase_clock=0
	enemies.append({"p":Vector2(size.x+260,size.y*.5),"v":0.0,"hp":boss_health,"max_hp":boss_health,"kind":5,"phase":0.0,"phase_index":1,"combat_state":"entering","fire":1.3,"add_clock":12.0,"pattern":3,"burst_left":0,"burst_delay":0.0,"boss":true})

func _update_boss_sequence(delta:float)->void:
	if not boss_spawned and boss_sequence_state=="idle":
		boss_sequence_state="warning";boss_warning_timer=3.0;boss_warning_overlay.visible=true;boss_warning_label.visible=true;boss_warning_material.set_shader_parameter("fade",1.0);sound_bank.play_event("boss_warning")
	if boss_sequence_state=="warning":
		boss_warning_timer=maxf(0,boss_warning_timer-delta)
		var fade:=clampf(boss_warning_timer/.55,0,1) if boss_warning_timer<.55 else 1.0
		boss_warning_material.set_shader_parameter("fade",fade);boss_warning_label.modulate.a=fade
		if boss_warning_timer<=0:
			boss_warning_overlay.visible=false;boss_warning_label.visible=false;boss_warning_label.modulate.a=1.0;_spawn_boss();sound_bank.play_event("boss05_arrival")
	elif boss_sequence_state=="active":
		boss_phase_clock+=delta

func _spawn_boss_pack(phase_index:int)->void:
	var count:=5+phase_index*2
	for index in count:
		var kind:=(index+phase_index)%5;var pattern:=mini(3,phase_index-1+(1 if index%3==0 else 0))
		enemies.append({"p":Vector2(size.x+120+(index%3)*85,150+fmod(index*117.0,maxf(180,size.y-260))),"v":175.0+phase_index*22,"hp":2+phase_index,"kind":kind,"phase":index*.8,"fire":.8+index*.18,"pattern":pattern,"burst_left":0,"burst_delay":0.0,"boss_add":true,"boss":false})

func _update_shots(delta: float) -> void:
	for i in range(shots.size()-1,-1,-1):
		if shots[i].type=="missile" and not enemies.is_empty():
			var target:Dictionary=enemies[0]
			for enemy in enemies:
				if enemy.p.distance_squared_to(shots[i].p)<target.p.distance_squared_to(shots[i].p):target=enemy
			var desired:Vector2=(target.p-shots[i].p).normalized()*600.0;shots[i].v=shots[i].v.lerp(desired,clampf(delta*4.2,0,1))
		shots[i].p += shots[i].v * delta
		if shots[i].p.x > size.x+100 or shots[i].p.y<60 or shots[i].p.y>size.y+40: shots.remove_at(i)

func _update_enemy_shots(delta:float)->void:
	for i in range(enemy_shots.size()-1,-1,-1):
		if i >= enemy_shots.size():continue
		enemy_shots[i].p+=enemy_shots[i].v*delta
		if respawn_timer<=0 and enemy_shots[i].p.distance_to(ship)<22:
			enemy_shots.remove_at(i)
			_damage_ship()
			continue
		if i >= enemy_shots.size():continue
		if enemy_shots[i].p.x < -50 or enemy_shots[i].p.y < 70 or enemy_shots[i].p.y > size.y+30:enemy_shots.remove_at(i)

func _update_enemies(delta: float) -> void:
	for ei in range(enemies.size()-1,-1,-1):
		if ei >= enemies.size(): continue
		var enemy := enemies[ei]; enemy.phase += delta*2.2
		if enemy.boss:_update_boss_actor(enemy,delta)
		else:enemy.p.x-=enemy.v*delta;enemy.p.y+=sin(enemy.phase)*42*delta
		enemy.fire-=delta
		enemy.burst_delay=float(enemy.get("burst_delay",0.0))-delta
		var can_fire:bool=not bool(enemy.boss) or String(enemy.combat_state)=="active"
		if can_fire and int(enemy.get("burst_left",0))>0 and enemy.burst_delay<=0:
			_fire_enemy_bullet(enemy,0.0,2)
			enemy.burst_left=int(enemy.burst_left)-1;enemy.burst_delay=.13
		elif can_fire and enemy.fire<=0 and enemy.p.x<size.x-80:
			_fire_enemy_pattern(enemy)
		for si in range(shots.size()-1,-1,-1):
			if si < shots.size() and shots[si].p.distance_to(enemy.p) < (105 if enemy.boss else 38):
				if not enemy.boss or String(enemy.combat_state)!="offscreen":enemy.hp-=float(shots[si].get("damage",1.0))
				shots.remove_at(si)
				if enemy.boss:_check_boss_phase_transition(enemy)
				if enemy.boss and int(enemy.phase_index)==1 and String(enemy.combat_state)=="retreating":enemy.hp=maxf(float(enemy.hp),float(enemy.max_hp)*.42)
				if enemy.hp<=0:_destroy_enemy(ei,enemy)
				break
		if ei >= enemies.size(): continue
		if respawn_timer<=0 and enemy.p.distance_to(ship) < (115 if enemy.boss else 42): _damage_ship(); if not enemy.boss: enemies.remove_at(ei); continue
		if enemy.p.x < -140: enemies.remove_at(ei)

func _update_boss_actor(enemy:Dictionary,delta:float)->void:
	var state:=String(enemy.combat_state);var phase_index:=int(enemy.phase_index);var target_x:=size.x-285.0
	match state:
		"entering":
			enemy.p.x=move_toward(float(enemy.p.x),target_x,115.0*delta);enemy.p.y=lerpf(float(enemy.p.y),size.y*.5,delta*1.8)
			if absf(float(enemy.p.x)-target_x)<1.0:enemy.combat_state="active";boss_sequence_state="active";boss_phase_clock=0;enemy.fire=1.0;sound_bank.play_event("boss05_charge")
		"active":
			enemy.p.x=target_x+sin(float(enemy.phase)*.34)*34;enemy.p.y=lerpf(float(enemy.p.y),size.y*.5+sin(float(enemy.phase))*(125+phase_index*18),delta*1.4)
			enemy.add_clock=float(enemy.add_clock)-delta
			if phase_index>=2 and enemy.add_clock<=0:
				_spawn_live_boss_adds(phase_index);enemy.add_clock=randf_range(15.0,23.0) if phase_index==2 else randf_range(9.0,15.0)
			if phase_index==2 and boss_phase_clock>=180.0:_begin_boss_retreat(enemy,3)
		"retreating":
			enemy.p.x+=175.0*delta;enemy.p.y=lerpf(float(enemy.p.y),size.y*.5,delta)
			var floor_hp:=float(enemy.max_hp)*(.42 if phase_index==1 else .08)
			enemy.hp=maxf(float(enemy.hp),floor_hp)
			if enemy.p.x>size.x+190:
				enemy.combat_state="offscreen";boss_sequence_state="pack";enemy.p.x=size.x+300;_spawn_boss_pack(int(enemy.get("next_phase",phase_index+1)))
		"offscreen":
			enemy.p=Vector2(size.x+300,size.y*.5)
			var pack_alive:=false
			for other in enemies:
				if not bool(other.boss) and bool(other.get("boss_add",false)):pack_alive=true;break
			if not pack_alive:
				enemy.phase_index=int(enemy.get("next_phase",phase_index+1));enemy.combat_state="entering";enemy.add_clock=10.0;boss_sequence_state="entering";sound_bank.play_event("boss15_phase_change" if enemy.phase_index>=3 else "boss10_prism_charge")

func _check_boss_phase_transition(enemy:Dictionary)->void:
	if String(enemy.combat_state)!="active":return
	if int(enemy.phase_index)==1 and float(enemy.hp)<=float(enemy.max_hp)*.75:_begin_boss_retreat(enemy,2)

func _begin_boss_retreat(enemy:Dictionary,next_phase:int)->void:
	if String(enemy.combat_state)!="active":return
	enemy.combat_state="retreating";enemy.next_phase=next_phase;enemy.burst_left=0;boss_sequence_state="retreating";sound_bank.play_event("warp_out")

func _spawn_live_boss_adds(phase_index:int)->void:
	var count:=2 if phase_index==2 else 3
	for index in count:
		var kind:=(index+phase_index*2)%5
		enemies.append({"p":Vector2(size.x+80+index*60,180+index*150),"v":210.0+phase_index*18,"hp":2+phase_index,"kind":kind,"phase":index*.7,"fire":1.0+index*.35,"pattern":mini(3,phase_index),"burst_left":0,"burst_delay":0.0,"boss_add":true,"boss":false})

func _fire_enemy_pattern(enemy:Dictionary)->void:
	if bool(enemy.boss):
		var boss_phase:=int(enemy.get("phase_index",1))
		if boss_phase==1:
			for angle in [-18.0,-9.0,0.0,9.0,18.0]:_fire_enemy_bullet(enemy,deg_to_rad(angle),1)
			enemy.fire=randf_range(1.15,1.55)
		elif boss_phase==2:
			enemy.burst_left=5;enemy.burst_delay=0.0;enemy.fire=randf_range(1.7,2.25)
		else:
			for index in 9:
				_fire_enemy_bullet(enemy,deg_to_rad(lerpf(-38.0,38.0,float(index)/8.0)),3)
			enemy.fire=randf_range(.62,.92)
		sound_bank.play_event("boss05_turret_fire")
		return
	var pattern:=3 if bool(enemy.boss) else int(enemy.get("pattern",0))
	match pattern:
		0:
			_fire_enemy_bullet(enemy,0.0,0)
			enemy.fire=randf_range(1.8,3.1)
		1:
			for angle in [-11.0,0.0,11.0]:_fire_enemy_bullet(enemy,deg_to_rad(angle),1)
			enemy.fire=randf_range(3.2,4.7)
		2:
			enemy.burst_left=randi_range(3,5);enemy.burst_delay=0.0
			enemy.fire=randf_range(5.0,7.0)
		_:
			var count:=7 if bool(enemy.boss) else 5
			for index in count:
				var angle:=deg_to_rad(lerpf(-24.0,24.0,float(index)/float(count-1)))
				_fire_enemy_bullet(enemy,angle,3)
			enemy.fire=randf_range(.8,1.25) if bool(enemy.boss) else randf_range(6.5,8.5)
	var fire_event:String="boss05_turret_fire" if bool(enemy.boss) else String(["drone_shot","dart_shot","spiker_shot","crescent_shot","gunship_shot"][mini(int(enemy.kind),4)])
	sound_bank.play_event(fire_event)

func _fire_enemy_bullet(enemy:Dictionary,angle_offset:float,style:int)->void:
	var direction:Vector2=(ship-enemy.p).normalized().rotated(angle_offset)
	var speed:=360.0 if bool(enemy.boss) else (315.0 if style>=2 else 270.0)
	enemy_shots.append({"p":enemy.p+Vector2(-35,0),"v":direction*speed,"boss":enemy.boss,"style":style})

func _destroy_enemy(index: int, enemy: Dictionary) -> void:
	score += 350 if enemy.boss else 15+enemy.kind*4
	_spawn_effect(enemy.p,"boss" if enemy.boss else "blast")
	_play_direct_sound(CUSTOM_EXPLOSION_SOUND,10.0 if enemy.boss else 8.0,"VR_Explosions")
	if enemy.boss or (int(enemy.kind)==2 and randf()<.28): pickups.append({"p":enemy.p,"kind":1 if enemy.boss else randi_range(0,4)})
	enemies.remove_at(index)
	if enemy.boss: _complete_level()

func _damage_ship() -> void:
	if invulnerable > 0: return
	if shield > 0: shield -= 1;sound_bank.play_event("shield_break" if shield==0 else "shield_hit")
	else:
		lives -= 1; power=maxi(1,power-1); _spawn_effect(ship,"ship");respawn_timer=1.05;enemies = enemies.filter(func(e): return e.boss or e.p.x > 520);enemy_shots.clear();_play_direct_sound(CUSTOM_EXPLOSION_SOUND,10.0,"VR_Explosions");sound_bank.play_event("ui_life_lost")
	invulnerable=2.0;screen_flash=.22
	if lives<=0: _finish()

func _update_pickups(delta: float) -> void:
	for i in range(pickups.size()-1,-1,-1):
		pickups[i].p.x -= 105*delta
		if pickups[i].p.distance_to(ship)<42:
			match int(pickups[i].kind):
				0: power=mini(5,power+1);_play_direct_sound(CUSTOM_POWERUP_SOUND,-1.0,"VR_Pickups")
				1: coins+=1; score+=25;_play_direct_sound(CUSTOM_POWERUP_SOUND,-1.0,"VR_Pickups")
				2: shield=mini(3,shield+1);_play_direct_sound(CUSTOM_POWERUP_SOUND,-1.0,"VR_Pickups");sound_bank.play_event("shield_on",-2.0)
				3: lives=mini(5,lives+1);_play_direct_sound(CUSTOM_POWERUP_SOUND,-1.0,"VR_Pickups")
				4: level_time=maxf(0,level_time-5);_play_direct_sound(CUSTOM_POWERUP_SOUND,-1.0,"VR_Pickups")
			pickups.remove_at(i)
		elif pickups[i].p.x < -40: pickups.remove_at(i)

func _play_direct_sound(stream:AudioStream,gain_db:float,bus_name:String)->void:
	# User-selected clips deliberately bypass the manifest cache so an old event
	# definition can never substitute one of the original sound-pack WAVs.
	var player:=AudioStreamPlayer.new()
	player.stream=stream
	player.volume_db=gain_db
	player.pitch_scale=randf_range(.98,1.02)
	player.bus=StringName(bus_name if AudioServer.get_bus_index(bus_name)>=0 else "Master")
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

func _spawn_effect(position:Vector2,kind:String)->void:
	var count:=34 if kind=="boss" else (22 if kind=="ship" else 12)
	var particles:Array[Dictionary]=[]
	for i in count:
		var angle:=randf()*TAU;var speed:=randf_range(90,420 if kind=="boss" else 250)
		particles.append({"p":position,"v":Vector2.from_angle(angle)*speed,"life":randf_range(.28,.8),"max":.8,"size":randf_range(2,7)})
	effects.append({"p":position,"age":0.0,"life":1.15 if kind=="boss" else .65,"kind":kind,"particles":particles})

func _update_effects(delta:float)->void:
	for i in range(effects.size()-1,-1,-1):
		effects[i].age+=delta
		var particles:Array=effects[i].particles
		for particle in particles:particle.p+=particle.v*delta;particle.v*=maxf(0,1.0-delta*2.8);particle.life-=delta
		if effects[i].age>=effects[i].life:effects.remove_at(i)

func _draw() -> void:
	if not started: _draw_space(); return
	_draw_space()
	_draw_ship()
	for shot in shots: _draw_shot(shot)
	for shot in enemy_shots:_draw_enemy_shot(shot)
	for enemy in enemies: _draw_enemy(enemy)
	for pickup in pickups: _draw_pickup(pickup)
	for effect in effects:_draw_effect(effect)
	if screen_flash>0:draw_rect(Rect2(Vector2.ZERO,size),Color(0.35,0.8,1.0,screen_flash*1.8),true)

func _draw_space()->void:
	# The fullscreen GPU shader is drawn behind this control. Keep only the fast
	# foreground streak layer here so gameplay remains readable at high speed.
	var streak:=22.0 if current_level%5==0 or transition_boost>0 else 8.0
	for star in stars_near:draw_line(star,star+Vector2(streak,0),Color(0.9,0.96,1.0,.82),2.0)

func _draw_ship() -> void:
	if respawn_timer>0 or (invulnerable>0 and int(invulnerable*12)%2==0):return
	draw_texture_rect_region(PLAYER_ART,Rect2(ship-Vector2(90,57),Vector2(180,114)),Rect2(0,0,418,360))

func _draw_enemy(enemy: Dictionary) -> void:
	if enemy.boss:
		var boss_index:=clampi(current_level/5-1,0,3);var boss_sources:=[Rect2(0,0,560,320),Rect2(620,0,630,380),Rect2(0,300,610,370),Rect2(640,300,610,380)];var boss_dimensions:=[Vector2(320,185),Vector2(320,193),Vector2(325,197),Vector2(320,200)];var dimensions:Vector2=boss_dimensions[boss_index]
		draw_texture_rect_region(BOSS_ART,Rect2(enemy.p-dimensions*.5,dimensions),boss_sources[boss_index])
		var bar:=Rect2(enemy.p+Vector2(-126,-108),Vector2(252,13));var ratio:=clampf(float(enemy.hp)/float(enemy.max_hp),0,1);draw_rect(bar,Color("#17051f"),true);draw_rect(Rect2(bar.position,Vector2(bar.size.x*ratio,bar.size.y)),Color("#ff46ca") if int(enemy.phase_index)<3 else Color("#ff5038"),true)
		for marker in [0.25,0.75]:draw_line(bar.position+Vector2(bar.size.x*marker,-3),bar.position+Vector2(bar.size.x*marker,bar.size.y+3),Color("#fff0c8"),2)
		draw_string(ThemeDB.fallback_font,enemy.p+Vector2(-52,-116),"PHASE %d / 3"%int(enemy.phase_index),HORIZONTAL_ALIGNMENT_LEFT,104,15,Color("#ffe8f8"))
	else:
		var kind:int=enemy.kind;var frame:=int(Time.get_ticks_msec()/150+kind)%3
		draw_texture_rect_region(ENEMY_ART,Rect2(enemy.p-Vector2(59,45),Vector2(118,90)),Rect2(frame*416.66,kind*250.0,416.66,250.0))

func _draw_shot(shot:Dictionary)->void:
	match String(shot.type):
		"pulse":
			draw_circle(shot.p,13,Color(1,.12,.78,.18));draw_circle(shot.p,7,Color("#ff45dc"));draw_circle(shot.p+Vector2(2,-1),3,Color.WHITE)
		"spread":
			var angle:float=(shot.v as Vector2).angle();draw_set_transform(shot.p,angle,Vector2.ONE);draw_colored_polygon(PackedVector2Array([Vector2(20,0),Vector2(-10,-8),Vector2(-4,0),Vector2(-10,8)]),Color("#5cecff"));draw_line(Vector2(-12,0),Vector2(-27,0),Color("#ff4ed5"),4);draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
		"laser":
			draw_line(shot.p-Vector2(34,0),shot.p+Vector2(44,0),Color(0.1,.8,1,.22),15);draw_line(shot.p-Vector2(32,0),shot.p+Vector2(44,0),Color("#28deff"),7);draw_line(shot.p-Vector2(30,0),shot.p+Vector2(44,0),Color.WHITE,2)
		"missile":
			var angle:float=(shot.v as Vector2).angle();var frame:=int(Time.get_ticks_msec()/90)%4;var regions:=[Rect2(18,390,230,160),Rect2(245,390,260,160),Rect2(515,390,300,160),Rect2(825,390,410,160)];draw_set_transform(shot.p,angle,Vector2.ONE);draw_texture_rect_region(WEAPON_ART,Rect2(-Vector2(48,21),Vector2(96,42)),regions[frame]);draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
		"beam":
			draw_texture_rect_region(WEAPON_ART,Rect2(shot.p-Vector2(58,19),Vector2(116,38)),Rect2(180,515,300,190))

func _draw_enemy_shot(shot:Dictionary)->void:
	var radius:=12.0 if shot.boss else 7.0;var style:=int(shot.get("style",0));var angle:float=(shot.v as Vector2).angle()
	match style:
		1:
			draw_set_transform(shot.p,angle,Vector2.ONE);draw_colored_polygon(PackedVector2Array([Vector2(-12,-5),Vector2(13,0),Vector2(-12,5)]),Color("#ff7adf"));draw_line(Vector2(-20,0),Vector2(-8,0),Color("#814dff"),4);draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
		2:
			draw_circle(shot.p,radius*1.7,Color(.25,.7,1,.16));draw_circle(shot.p,radius,Color("#5cecff"));draw_circle(shot.p,radius*.38,Color.WHITE)
		3:
			draw_set_transform(shot.p,angle,Vector2.ONE);draw_line(Vector2(-17,0),Vector2(15,0),Color(1,.1,.7,.22),11);draw_line(Vector2(-13,0),Vector2(13,0),Color("#ff48d4"),5);draw_circle(Vector2(12,0),3,Color.WHITE);draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
		_:
			draw_circle(shot.p,radius*1.8,Color(1,.1,.7,.18));draw_circle(shot.p,radius,Color("#ff45ca"));draw_circle(shot.p,radius*.42,Color.WHITE)

func _draw_fighter(p:Vector2,kind:int,phase:float)->void:
	var cyan:=Color("#53e7ff");var magenta:=Color("#ff4fce");var dark:=Color("#14122d");var glow:=7.0+sin(phase*4.0)*2.0
	match kind:
		0:
			draw_colored_polygon(PackedVector2Array([p+Vector2(35,0),p+Vector2(-18,-22),p+Vector2(-8,0),p+Vector2(-18,22)]),dark);draw_polyline(PackedVector2Array([p+Vector2(35,0),p+Vector2(-18,-22),p+Vector2(-8,0),p+Vector2(-18,22),p+Vector2(35,0)]),cyan,3);draw_circle(p+Vector2(5,0),glow,magenta)
		1:
			draw_circle(p,27,dark);draw_circle(p,27,magenta,false,4);draw_circle(p,12,cyan);for a in 6:draw_line(p+Vector2.from_angle(a*TAU/6)*27,p+Vector2.from_angle(a*TAU/6)*39,magenta,5)
		2:
			for a in 3:var q:=p+Vector2.from_angle(phase+a*TAU/3)*22;draw_circle(q,10,dark);draw_circle(q,10,cyan,false,3);draw_circle(q,3,magenta)
		3:
			draw_colored_polygon(PackedVector2Array([p+Vector2(30,0),p+Vector2(10,-27),p+Vector2(-28,-14),p+Vector2(-17,0),p+Vector2(-28,14),p+Vector2(10,27)]),dark);draw_polyline(PackedVector2Array([p+Vector2(30,0),p+Vector2(10,-27),p+Vector2(-28,-14),p+Vector2(-17,0),p+Vector2(-28,14),p+Vector2(10,27),p+Vector2(30,0)]),magenta,4);draw_circle(p,8,cyan)
		_:
			draw_circle(p,25,Color("#402563"));for a in 8:draw_line(p,p+Vector2.from_angle(a*TAU/8+phase*.15)*37,cyan,3);draw_circle(p,10,magenta)

func _draw_boss(enemy:Dictionary)->void:
	var p:Vector2=enemy.p;var phase:float=enemy.phase;var dark:=Color("#17102d");var magenta:=Color("#ff3bc8");var cyan:=Color("#42e9ff")
	draw_colored_polygon(PackedVector2Array([p+Vector2(118,0),p+Vector2(62,-66),p+Vector2(-30,-82),p+Vector2(-105,-38),p+Vector2(-130,0),p+Vector2(-105,38),p+Vector2(-30,82),p+Vector2(62,66)]),dark)
	draw_polyline(PackedVector2Array([p+Vector2(118,0),p+Vector2(62,-66),p+Vector2(-30,-82),p+Vector2(-105,-38),p+Vector2(-130,0),p+Vector2(-105,38),p+Vector2(-30,82),p+Vector2(62,66),p+Vector2(118,0)]),magenta,6)
	draw_circle(p,43,Color("#311b55"));draw_circle(p,31,magenta);draw_circle(p,17,Color("#ffb032"));draw_circle(p,8+sin(phase*6)*3,Color.WHITE)
	for a in 4:var q:=p+Vector2.from_angle(phase*.22+a*TAU/4)*72;draw_circle(q,19,dark);draw_circle(q,19,cyan,false,4);draw_circle(q,6,magenta)

func _draw_effect(effect:Dictionary)->void:
	var ratio:=clampf(effect.age/effect.life,0,1);var outer:=Color("#ff4fbd").lerp(Color("#ffb13c"),ratio);outer.a=1.0-ratio
	var frame:=clampi(int(ratio*7.99),0,7);var row_y:=880.0 if effect.kind=="boss" else (535.0 if effect.kind=="ship" else 235.0);var row_h:=340.0 if effect.kind=="boss" else (285.0 if effect.kind=="ship" else 225.0);var source:=Rect2(frame*156.75,row_y,156.75,row_h);var scale:=245.0 if effect.kind=="boss" else (175.0 if effect.kind=="ship" else 112.0)
	draw_texture_rect_region(EXPLOSION_ART,Rect2(effect.p-Vector2.ONE*scale*.5,Vector2.ONE*scale),source)
	for particle in effect.particles:
		if particle.life>0:var color:=Color("#fff2a8");color.a=clampf(particle.life/particle.max,0,1);draw_circle(particle.p,maxf(1,particle.size*color.a),color)

func _draw_pickup(pickup: Dictionary) -> void:
	var sources:=[Rect2(10,410,180,250),Rect2(625,690,185,275),Rect2(320,410,185,250),Rect2(10,690,180,275),Rect2(940,690,190,275)];var source:Rect2=sources[int(pickup.kind)];var pulse:=1.0+sin(Time.get_ticks_msec()*.008+float(pickup.kind))*.06;var dimensions:=Vector2.ONE*76.0*pulse
	draw_texture_rect_region(PICKUP_ART,Rect2(pickup.p-dimensions*.5,dimensions),source)

func _finish() -> void:
	if ended:return
	ended=true;_save_high_score()
	var payout:=clampi(8+score/120+coins*3+(current_level-1)*4+(10 if lives>0 else 0),8,75)
	sound_bank.stop_loop("engine",.15);sound_bank.play_event("ui_game_over");sound_bank.play_event("engine_power_down");await get_tree().create_timer(1.6).timeout;sound_bank.stop_all()
	finished.emit(payout,"%s\nLEVEL %02d • SCORE %06d • %d COINS\nCONTINUE CODE %s\n$%d PAYOUT"%["RUN COMPLETE" if lives>0 else "SHIP DESTROYED",current_level,score,coins,_continue_code(current_level),payout]);queue_free()
