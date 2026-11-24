extends Node3D

enum State { MENU, PLAYING, GAMEOVER, PAUSED }

var state: State = State.MENU
var speed := 0.0
var distance := 0.0
var run_coins := 0
var data: Dictionary = {}
var track: Track
var player: Player
var hud: Hud
var audio: AudioManager
var camera: Camera3D
var cam_base := Vector3.ZERO
var shake := 0.0
var smoke := false
var smoke_t := 0.0
var smoke_step := 0
var burst: CPUParticles3D
var _touch_start := Vector2.ZERO

func _ready() -> void:
	data = Save.load_data()
	_build_world()
	audio = AudioManager.new()
	add_child(audio)
	track = Track.new()
	add_child(track)
	player = Player.new()
	add_child(player)
	track.setup(player)
	track.reset()
	track.active = false
	_spawn_character()
	hud = Hud.new()
	add_child(hud)
	hud.play_pressed.connect(_on_play)
	hud.restart_pressed.connect(_on_play)
	hud.menu_pressed.connect(_on_menu)
	hud.pause_pressed.connect(_toggle_pause)
	hud.char_prev.connect(func(): _cycle_char(-1))
	hud.char_next.connect(func(): _cycle_char(1))
	track.coin_collected.connect(_on_coin)
	track.player_hit.connect(_on_hit)
	burst = _make_burst()
	add_child(burst)
	hud.show_menu(data, Characters.list())
	hud.set_char(_char(), _char_unlocked())
	audio.play_music()
	if "--smoke-test" in OS.get_cmdline_user_args():
		smoke = true
		player.smoke = true
		print("SMOKE_MODE_ON")

func _build_world() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.25, 0.42, 0.68)
	sky_mat.sky_horizon_color = Color(1.0, 0.62, 0.3)
	sky_mat.ground_bottom_color = Color(0.35, 0.24, 0.16)
	sky_mat.ground_horizon_color = Color(0.95, 0.6, 0.35)
	sky_mat.sun_angle_max = 30.0
	sky.sky_material = sky_mat
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.6
	env.fog_enabled = true
	env.fog_light_color = Color(1.0, 0.65, 0.4)
	env.fog_density = 0.016
	env.fog_sky_affect = 0.6
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.glow_enabled = true
	env.glow_intensity = 0.7
	env.glow_bloom = 0.08
	env.glow_hdr_threshold = 1.0
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52, -32, 0)
	sun.light_color = Color(1.0, 0.87, 0.68)
	sun.light_energy = 1.35
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 80.0
	add_child(sun)
	camera = Camera3D.new()
	add_child(camera)
	camera.position = Vector3(0, 4.3, 5.6)
	camera.look_at(Vector3(0, 1.4, -8), Vector3.UP)
	camera.fov = 72.0
	camera.current = true
	cam_base = camera.position

func _make_burst() -> CPUParticles3D:
	var p := CPUParticles3D.new()
	p.one_shot = true
	p.explosiveness = 0.9
	p.amount = 24
	p.lifetime = 0.6
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 0.25
	p.direction = Vector3(0, 1, 0)
	p.spread = 50.0
	p.initial_velocity_min = 2.5
	p.initial_velocity_max = 6.0
	p.gravity = Vector3(0, -9, 0)
	p.scale_amount_min = 0.08
	p.scale_amount_max = 0.16
	p.color = Color(1.0, 0.85, 0.3)
	var sm := SphereMesh.new()
	sm.radius = 0.5
	sm.height = 1.0
	p.mesh = sm
	p.emitting = false
	return p

func _char() -> Dictionary:
	var chars := Characters.list()
	var idx: int = clampi(int(data.get("selected", 0)), 0, chars.size() - 1)
	return chars[idx]

func _char_unlocked() -> bool:
	return _char().id in data.get("unlocked", [0])

func _spawn_character() -> void:
	var ch := _char()
	player.setup(track, ch.file, ch.tint)

func _on_play() -> void:
	data = Save.load_data()
	run_coins = 0
	distance = 0.0
	speed = 8.0
	shake = 0.0
	state = State.PLAYING
	track.reset()
	track.active = true
	track.difficulty = 0.0
	_spawn_character()
	player.reset()
	hud.show_hud()
	hud.set_score(0)
	hud.set_coins(0)
	hud.set_distance(0)
	audio.sfx("click")
	audio.play_music()

func _on_menu() -> void:
	state = State.MENU
	track.active = false
	player.reset()
	hud.show_menu(data, Characters.list())
	hud.set_char(_char(), _char_unlocked())
	audio.sfx("click")

func _toggle_pause() -> void:
	if state == State.PLAYING:
		state = State.PAUSED
		get_tree().paused = true
		hud.set_paused(true)
	elif state == State.PAUSED:
		state = State.PLAYING
		get_tree().paused = false
		hud.set_paused(false)

func _cycle_char(dir: int) -> void:
	var chars := Characters.list()
	var n := chars.size()
	var idx: int = int(data.get("selected", 0))
	for i in n:
		idx = (idx + dir + n) % n
		var ch: Dictionary = chars[idx]
		if ch.id in data.get("unlocked", [0]):
			data.selected = idx
			Save.save_data(data)
			hud.set_char(ch, true)
			audio.sfx("click")
			return
		if int(data.get("coins", 0)) >= int(ch.cost):
			data.coins = int(data.coins) - int(ch.cost)
			data.unlocked.append(ch.id)
			data.selected = idx
			Save.save_data(data)
			hud.show_menu(data, chars)
			hud.set_char(ch, true)
			audio.sfx("jingle")
			return
		else:
			hud.set_char(ch, false)
			audio.sfx("click")
			return

func _on_hit(_ob) -> void:
	if state != State.PLAYING:
		return
	if smoke:
		return
	state = State.GAMEOVER
	track.active = false
	player.die()
	shake = 0.6
	audio.sfx("hit")
	audio.sfx("gameover")
	var score := int(distance) + run_coins * 10
	data.coins = int(data.get("coins", 0)) + run_coins
	var new_best := false
	if score > int(data.get("best", 0)):
		data.best = score
		new_best = true
	Save.save_data(data)
	await get_tree().create_timer(1.0).timeout
	if state == State.GAMEOVER:
		hud.show_gameover(score, int(data.best), run_coins, new_best)

func _on_coin(_lane, pos: Vector3) -> void:
	if state != State.PLAYING:
		return
	run_coins += 1
	audio.sfx("coin" if run_coins % 2 == 0 else "coin2")
	burst.position = pos + Vector3(0, 0.2, 0)
	burst.restart()

func _process(delta: float) -> void:
	if smoke:
		_smoke(delta)
	match state:
		State.PLAYING:
			distance += speed * delta
			speed = minf(8.0 + distance * 0.02, 26.0)
			track.speed = speed
			track.difficulty = clampf(distance / 900.0, 0.0, 1.0)
			var score := int(distance) + run_coins * 10
			hud.set_score(score)
			hud.set_coins(run_coins)
			hud.set_distance(int(distance))
			camera.fov = lerpf(72.0, 84.0, clampf((speed - 8.0) / 18.0, 0.0, 1.0))
			if shake > 0.0:
				shake = maxf(0.0, shake - delta * 1.5)
				camera.position = cam_base + Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * shake * 0.4
			else:
				camera.position = cam_base
			if player.y < -8.0 and not smoke:
				_on_hit(null)
		_:
			track.active = false

func _smoke(delta: float) -> void:
	smoke_t += delta
	match smoke_step:
		0:
			if smoke_t > 0.5:
				_on_play()
				smoke_step = 1
		1:
			if smoke_t > 1.5:
				player.switch_lane(-1)
				smoke_step = 2
		2:
			if smoke_t > 2.5:
				player.jump()
				smoke_step = 3
		3:
			if smoke_t > 3.5:
				player.switch_lane(1)
				player.switch_lane(1)
				smoke_step = 4
		4:
			if smoke_t > 4.5:
				player.slide()
				smoke_step = 5
		5:
			if smoke_t > 5.5:
				player.jump()
				smoke_step = 6
		6:
			if smoke_t > 8.0:
				var score := int(distance) + run_coins * 10
				var ok := distance > 20.0 and player.anim != null and track.segments.size() > 0
				print("SMOKE_TEST_OK dist=%.1f score=%d coins=%d speed=%.1f anim=%s segs=%d ground=%s" % [distance, score, run_coins, speed, str(player.anim != null), track.segments.size(), str(track.ground_at(0.0))])
				print("SMOKE_RESULT=" + ("PASS" if ok else "FAIL"))
				get_tree().quit(0 if ok else 1)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
				if state == State.MENU or state == State.GAMEOVER:
					_on_play()
				elif state == State.PLAYING:
					player.jump()
			KEY_LEFT, KEY_A:
				if state == State.PLAYING:
					player.switch_lane(-1)
			KEY_RIGHT, KEY_D:
				if state == State.PLAYING:
					player.switch_lane(1)
			KEY_UP, KEY_W:
				if state == State.PLAYING:
					player.jump()
			KEY_DOWN, KEY_S:
				if state == State.PLAYING:
					player.slide()
			KEY_ESCAPE, KEY_P:
				_toggle_pause()
	elif event is InputEventScreenTouch:
		if event.pressed:
			_touch_start = event.position
		elif state == State.PLAYING:
			var d: Vector2 = (event as InputEventScreenTouch).position - _touch_start
			if absf(d.x) > 60.0 and absf(d.x) > absf(d.y):
				player.switch_lane(1 if d.x > 0.0 else -1)
			elif d.y < -60.0:
				player.jump()
			elif d.y > 60.0:
				player.slide()
