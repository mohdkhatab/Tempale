class_name Track
extends Node3D

signal coin_collected(lane, world_pos)
signal player_hit(obstacle)

const SEG_LEN := 24.0
const SEG_COUNT := 7
const LANE_X := [-2.2, 0.0, 2.2]

var segments: Array = []
var player: Node3D
var speed := 0.0
var active := false
var difficulty := 0.0
var rng := RandomNumberGenerator.new()
var coin_scene: PackedScene
var _counter := 0

func _ready() -> void:
	rng.randomize()
	coin_scene = load("res://assets/models/coinGold.glb")

func setup(p: Node3D) -> void:
	player = p

func reset() -> void:
	for c in get_children():
		c.queue_free()
	segments.clear()
	_counter = 0
	difficulty = 0.0
	var front := 8.0
	for i in SEG_COUNT:
		_spawn_segment(front - i * SEG_LEN, i < 2)

func ground_at(z: float) -> bool:
	for seg in segments:
		if z <= seg.z and z >= seg.z - SEG_LEN:
			var local: float = seg.z - z
			if seg.gap_start >= 0.0 and local >= seg.gap_start and local <= seg.gap_start + seg.gap_len:
				return false
			return true
	return true

func _spawn_segment(front_z: float, tutorial: bool) -> void:
	var seg := {"node": Node3D.new(), "z": front_z, "obstacles": [], "coins": [], "gap_start": -1.0, "gap_len": 0.0}
	seg.node.name = "Segment%d" % _counter
	add_child(seg.node)
	seg.node.position.z = front_z
	_counter += 1
	_build(seg, tutorial)
	segments.append(seg)

func _recycle(seg: Dictionary) -> void:
	var front := -INF
	for s in segments:
		front = maxf(front, s.z)
	seg.z = front - SEG_LEN
	seg.node.position.z = seg.z
	for c in seg.node.get_children():
		c.queue_free()
	seg.obstacles.clear()
	seg.coins.clear()
	seg.gap_start = -1.0
	seg.gap_len = 0.0
	_build(seg, false)

func _build(seg: Dictionary, tutorial: bool) -> void:
	var n: Node3D = seg.node
	var stone := Props.mat(Color(1, 1, 1), "res://assets/textures/sandstone.png", 0.35)
	var dirt := Props.mat(Color(1, 1, 1), "res://assets/textures/dirt.png", 0.25)
	var brick := Props.mat(Color(1, 1, 1), "res://assets/textures/bricks.png", 0.5)
	var L := SEG_LEN
	var gap_start := -1.0
	var gap_len := 0.0
	if not tutorial and rng.randf() < 0.10 + 0.16 * difficulty:
		gap_start = rng.randf_range(6.0, L - 9.0)
		gap_len = rng.randf_range(3.0, 3.0 + 2.5 * difficulty)
	seg.gap_start = gap_start
	seg.gap_len = gap_len
	if gap_start < 0.0:
		n.add_child(Props.box(Vector3(8.6, 0.4, L), stone, Vector3(0, -0.2, -L / 2.0)))
	else:
		var l1 := gap_start
		var l2 := L - gap_start - gap_len
		if l1 > 1.0:
			n.add_child(Props.box(Vector3(8.6, 0.4, l1), stone, Vector3(0, -0.2, -l1 / 2.0)))
		if l2 > 1.0:
			n.add_child(Props.box(Vector3(8.6, 0.4, l2), stone, Vector3(0, -0.2, -(gap_start + gap_len + l2 / 2.0))))
	n.add_child(Props.box(Vector3(20.0, 0.4, L), dirt, Vector3(-14.3, -0.22, -L / 2.0)))
	n.add_child(Props.box(Vector3(20.0, 0.4, L), dirt, Vector3(14.3, -0.22, -L / 2.0)))
	n.add_child(Props.box(Vector3(0.4, 0.8, L), brick, Vector3(-4.4, 0.4, -L / 2.0)))
	n.add_child(Props.box(Vector3(0.4, 0.8, L), brick, Vector3(4.4, 0.4, -L / 2.0)))
	for lz in [4.0, 12.0, 20.0]:
		n.add_child(Props.pillar(3.0, -4.4, -lz, fmod(lz + _counter, 2.0) == 0.0))
		n.add_child(Props.pillar(3.0, 4.4, -lz, fmod(lz + _counter + 1.0, 2.0) == 0.0))
	if _counter % 3 == 1:
		n.add_child(Props.arch(0.0, -12.0))
	if _counter % 5 == 2:
		n.add_child(Props.gopuram(-L + 4.0))
	for i in 3:
		var lz := rng.randf_range(2.0, L - 2.0)
		var side := -1.0 if rng.randf() < 0.5 else 1.0
		n.add_child(Props.tree(side * rng.randf_range(6.5, 14.0), -lz, rng))
		if rng.randf() < 0.4:
			n.add_child(Props.rock(side * rng.randf_range(6.0, 12.0), -rng.randf_range(2.0, L - 2.0), rng))
	if _counter % 2 == 0:
		n.add_child(Props.hill(-rng.randf_range(24.0, 40.0), -rng.randf_range(4.0, L - 4.0), rng))
		n.add_child(Props.hill(rng.randf_range(24.0, 40.0), -rng.randf_range(4.0, L - 4.0), rng))
	if _counter % 4 == 3:
		n.add_child(Props.far_temple(-30.0, -L / 2.0))
		n.add_child(Props.far_temple(32.0, -L / 2.0))
	if not tutorial:
		if seg.gap_start > 0.0:
			_spawn_coins(seg)
		else:
			_spawn_obstacles(seg)
			_spawn_coins(seg)
	else:
		_spawn_coins(seg)

func _spawn_obstacles(seg: Dictionary) -> void:
	var n: Node3D = seg.node
	var d := difficulty
	if rng.randf() > 0.55 + 0.35 * d:
		return
	var lz := rng.randf_range(8.0, SEG_LEN - 6.0)
	var r := rng.randf()
	var type := "pillar"
	if r < 0.4:
		type = "pillar"
	elif r < 0.7:
		type = "barrier"
	else:
		type = "beam"
	var lanes := [0, 1, 2]
	lanes.shuffle()
	var count := 2 if rng.randf() < d * 0.7 else 1
	if type == "pillar":
		count = mini(count, 2)
	for i in count:
		var lane: int = lanes[i]
		var node: Node3D
		match type:
			"pillar":
				node = Props.lane_pillar(LANE_X[lane], -lz)
			"barrier":
				node = Props.barrier(LANE_X[lane], -lz)
			"beam":
				node = Props.beam(LANE_X[lane], -lz)
		n.add_child(node)
		seg.obstacles.append({"node": node, "lane": lane, "type": type, "lz": -lz, "hit": false})

func _spawn_coins(seg: Dictionary) -> void:
	if rng.randf() < 0.25:
		return
	var lane: int = rng.randi_range(0, 2)
	var lz0 := rng.randf_range(6.0, SEG_LEN - 12.0)
	var count := rng.randi_range(5, 8)
	for i in count:
		_add_coin(seg, lane, -lz0 - i * 1.2, 0.6)
	if seg.gap_start > 0.0 and rng.randf() < 0.6:
		for i in 5:
			var t := i / 4.0
			_add_coin(seg, lane, -(seg.gap_start + seg.gap_len * t), 0.6 + sin(t * PI) * 1.6)

func _add_coin(seg: Dictionary, lane: int, lz: float, y: float) -> void:
	var inst: Node3D = coin_scene.instantiate()
	inst.position = Vector3(LANE_X[lane], y, lz)
	inst.scale = Vector3.ONE * 0.9
	seg.node.add_child(inst)
	seg.coins.append({"node": inst, "lane": lane, "lz": lz, "taken": false})

func _process(delta: float) -> void:
	if not active:
		return
	for seg in segments:
		seg.z += speed * delta
		seg.node.position.z = seg.z
		if seg.z - SEG_LEN > 14.0:
			_recycle(seg)
	for seg in segments:
		for ob in seg.obstacles:
			if ob.hit:
				continue
			var wz: float = seg.z + ob.lz
			if absf(wz) < 0.6 and ob.lane == player.lane:
				var hit := false
				match ob.type:
					"pillar":
						hit = true
					"barrier":
						hit = player.y < 0.75
					"beam":
						hit = player.y < 1.45 and not player.sliding
				if hit:
					ob.hit = true
					emit_signal("player_hit", ob)
		for c in seg.coins:
			if c.taken:
				continue
			c.node.rotation.y += 6.0 * delta
			var wz: float = seg.z + c.lz
			if absf(wz) < 0.7 and c.lane == player.lane and absf(player.y - 0.6) < 1.2:
				c.taken = true
				emit_signal("coin_collected", c.lane, Vector3(LANE_X[c.lane], 0.6, wz))
				c.node.queue_free()
