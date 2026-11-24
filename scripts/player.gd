class_name Player
extends Node3D

const LANE_X := [-2.2, 0.0, 2.2]
const GRAV := 26.0
const JUMP_V := 9.5

var lane := 1
var y := 0.0
var vy := 0.0
var jumping := false
var sliding := false
var slide_timer := 0.0
var alive := true
var smoke := false
var track: Track
var character_root: Node3D = null
var anim: AnimationPlayer = null
var base_scale := Vector3.ONE

func setup(t: Track, char_file: String, tint: Color) -> void:
	track = t
	if character_root:
		character_root.queue_free()
		character_root = null
	var scene: PackedScene = load(char_file)
	character_root = scene.instantiate()
	add_child(character_root)
	character_root.rotation.y = PI
	anim = _find_anim(character_root)
	_normalize_scale()
	_tint(tint)
	if anim and anim.has_animation("Running_A"):
		anim.play("Running_A")

func reset() -> void:
	lane = 1
	position = Vector3(LANE_X[1], 0.0, 0.0)
	y = 0.0
	vy = 0.0
	jumping = false
	sliding = false
	slide_timer = 0.0
	alive = true
	if character_root:
		character_root.scale = base_scale
	if anim and anim.has_animation("Running_A"):
		anim.play("Running_A", 0.2)

func _process(delta: float) -> void:
	if not alive:
		return
	position.x = lerpf(position.x, LANE_X[lane], minf(1.0, 14.0 * delta))
	if jumping:
		vy -= GRAV * delta
		y += vy * delta
		if y <= 0.0 and track and track.ground_at(0.0):
			y = 0.0
			vy = 0.0
			jumping = false
			if anim and anim.has_animation("Running_A"):
				anim.play("Running_A", 0.15)
		position.y = y
	elif track and not track.ground_at(0.0):
		jumping = true
		vy = -1.0
		position.y = 0.0
	else:
		position.y = 0.0
	if sliding:
		slide_timer -= delta
		if slide_timer <= 0.0:
			sliding = false
	if character_root:
		var target_sy := base_scale.y * (0.55 if sliding else 1.0)
		character_root.scale.y = lerpf(character_root.scale.y, target_sy, minf(1.0, 10.0 * delta))

func switch_lane(dir: int) -> void:
	if not alive:
		return
	lane = clampi(lane + dir, 0, 2)

func jump() -> void:
	if not alive or jumping or sliding:
		return
	if track and not track.ground_at(0.0):
		return
	jumping = true
	vy = JUMP_V
	if anim and anim.has_animation("Jump_Full_Long"):
		anim.play("Jump_Full_Long")

func slide() -> void:
	if not alive or sliding:
		return
	if jumping and y > 1.2:
		vy = -18.0
		return
	sliding = true
	slide_timer = 0.7
	if anim and anim.has_animation("Dodge_Forward"):
		anim.play("Dodge_Forward")

func die() -> void:
	if not alive:
		return
	alive = false
	if anim and anim.has_animation("Death_A"):
		anim.play("Death_A")

func _find_anim(n: Node) -> AnimationPlayer:
	if n is AnimationPlayer:
		return n
	for c in n.get_children():
		var r := _find_anim(c)
		if r:
			return r
	return null

func _normalize_scale() -> void:
	var aabb := AABB()
	var first := true
	for node in character_root.find_children("*", "MeshInstance3D", true, false):
		var a: AABB = node.get_global_transform() * node.get_aabb()
		if first:
			aabb = a
			first = false
		else:
			aabb = aabb.merge(a)
	if aabb.size.y > 0.01:
		var s := 1.7 / aabb.size.y
		base_scale = Vector3(s, s, s)
		character_root.scale = base_scale

func _tint(tint: Color) -> void:
	for node in character_root.find_children("*", "MeshInstance3D", true, false):
		var m := StandardMaterial3D.new()
		m.albedo_color = tint
		m.roughness = 0.8
		var orig: Material = node.get_active_material(0)
		if orig is StandardMaterial3D and orig.albedo_texture:
			m.albedo_texture = orig.albedo_texture
		node.set_surface_override_material(0, m)
