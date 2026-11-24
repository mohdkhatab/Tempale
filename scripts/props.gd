class_name Props

static var _mats := {}
static var _tex := {}

static func tex(path: String) -> Texture2D:
	if not _tex.has(path):
		_tex[path] = load(path)
	return _tex[path]

static func mat(albedo: Color, texture_path := "", uv_scale := 1.0, roughness := 0.9, metallic := 0.0) -> StandardMaterial3D:
	var key := str(albedo) + "|" + texture_path + "|" + str(uv_scale) + "|" + str(roughness) + "|" + str(metallic)
	if _mats.has(key):
		return _mats[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = albedo
	if texture_path != "":
		m.albedo_texture = tex(texture_path)
		m.uv1_scale = Vector3(uv_scale, uv_scale, uv_scale)
	m.roughness = roughness
	m.metallic = metallic
	_mats[key] = m
	return m

static func emissive(color: Color, energy: float) -> StandardMaterial3D:
	var key := "emis|" + str(color) + "|" + str(energy)
	if _mats.has(key):
		return _mats[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.emission_enabled = true
	m.emission = color
	m.emission_energy_multiplier = energy
	_mats[key] = m
	return m

static func box(size: Vector3, material: Material, pos: Vector3, rot := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.material_override = material
	mi.position = pos
	mi.rotation = rot
	return mi

static func cyl(radius: float, height: float, material: Material, pos: Vector3, radial := 10) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = radius
	cm.bottom_radius = radius
	cm.height = height
	cm.radial_segments = radial
	mi.mesh = cm
	mi.material_override = material
	mi.position = pos
	return mi

static func sph(radius: float, material: Material, pos: Vector3, scale := Vector3.ONE) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = radius
	sm.height = radius * 2.0
	sm.radial_segments = 10
	sm.rings = 6
	mi.mesh = sm
	mi.material_override = material
	mi.position = pos
	mi.scale = scale
	return mi

static func pillar(h: float, x: float, z: float, with_diya := false) -> Node3D:
	var g := Node3D.new()
	g.position = Vector3(x, 0, z)
	var stone := mat(Color(1, 1, 1), "res://assets/textures/sandstone.png", 0.5)
	g.add_child(box(Vector3(0.95, 0.3, 0.95), stone, Vector3(0, 0.15, 0)))
	g.add_child(cyl(0.3, h - 0.6, stone, Vector3(0, 0.3 + (h - 0.6) / 2.0, 0)))
	g.add_child(box(Vector3(0.85, 0.3, 0.85), stone, Vector3(0, h - 0.15, 0)))
	if with_diya:
		g.add_child(diya(Vector3(0, h + 0.12, 0)))
	return g

static func diya(pos: Vector3) -> Node3D:
	var g := Node3D.new()
	g.position = pos
	var brass := mat(Color(0.85, 0.65, 0.25), "", 1.0, 0.4, 0.8)
	g.add_child(cyl(0.14, 0.08, brass, Vector3(0, 0, 0), 8))
	g.add_child(sph(0.1, emissive(Color(1.0, 0.55, 0.15), 4.0), Vector3(0, 0.12, 0)))
	return g

static func arch(x := 0.0, z := 0.0) -> Node3D:
	var g := Node3D.new()
	g.position = Vector3(x, 0, z)
	var stone := mat(Color(1, 1, 1), "res://assets/textures/bricks.png", 0.6)
	g.add_child(pillar(3.4, -3.0, 0))
	g.add_child(pillar(3.4, 3.0, 0))
	g.add_child(box(Vector3(7.0, 0.6, 1.0), stone, Vector3(0, 3.7, 0)))
	g.add_child(banner(Vector3(0, 3.0, 0.55)))
	g.add_child(diya(Vector3(-3.0, 3.55, 0)))
	g.add_child(diya(Vector3(3.0, 3.55, 0)))
	return g

static func banner(pos: Vector3) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(1.3, 1.9)
	mi.mesh = pm
	mi.material_override = mat(Color(1, 1, 1), "res://assets/textures/banner.png", 1.0)
	mi.position = pos
	return mi

static func gopuram(z: float) -> Node3D:
	var g := Node3D.new()
	g.position = Vector3(0, 0, z)
	var colors := [Color(0.95, 0.5, 0.1), Color(0.85, 0.2, 0.15), Color(0.98, 0.93, 0.8)]
	for side in [-4.6, 4.6]:
		var t := Node3D.new()
		t.position = Vector3(side, 0, 0)
		for i in 5:
			var w := 2.0 - i * 0.3
			t.add_child(box(Vector3(w, 0.75, 1.4), mat(colors[i % 3]), Vector3(0, 0.375 + i * 0.75, 0)))
		t.add_child(sph(0.28, mat(Color(0.95, 0.75, 0.2), "", 1.0, 0.3, 0.7), Vector3(0, 0.375 + 5 * 0.75 + 0.25, 0)))
		g.add_child(t)
	g.add_child(box(Vector3(11.4, 0.7, 1.6), mat(colors[1]), Vector3(0, 4.4, 0)))
	g.add_child(banner(Vector3(0, 3.6, 0.85)))
	g.add_child(diya(Vector3(-4.6, 4.4, 0)))
	g.add_child(diya(Vector3(4.6, 4.4, 0)))
	return g

static func tree(x: float, z: float, rng: RandomNumberGenerator) -> Node3D:
	var g := Node3D.new()
	g.position = Vector3(x, 0, z)
	var trunk := mat(Color(0.45, 0.3, 0.18))
	var leaf := mat(Color(0.2 + rng.randf() * 0.15, 0.45 + rng.randf() * 0.2, 0.15))
	g.add_child(cyl(0.14, 1.5, trunk, Vector3(0, 0.75, 0), 7))
	g.add_child(sph(0.9, leaf, Vector3(0, 1.9, 0)))
	g.add_child(sph(0.65, leaf, Vector3(0.5, 1.5, 0.2)))
	g.add_child(sph(0.6, leaf, Vector3(-0.45, 1.55, -0.15)))
	return g

static func rock(x: float, z: float, rng: RandomNumberGenerator) -> Node3D:
	var g := Node3D.new()
	g.position = Vector3(x, 0, z)
	g.add_child(sph(0.5 + rng.randf() * 0.5, mat(Color(0.55, 0.52, 0.48)), Vector3(0, 0.25, 0), Vector3(1.0, 0.6, 1.0)))
	return g

static func hill(x: float, z: float, rng: RandomNumberGenerator) -> Node3D:
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.5
	cm.bottom_radius = 7.0 + rng.randf() * 5.0
	cm.height = 7.0
	cm.radial_segments = 8
	mi.mesh = cm
	mi.material_override = mat(Color(0.25, 0.38, 0.22))
	mi.position = Vector3(x, 1.0, z)
	mi.scale.y = 0.55
	return mi

static func far_temple(x: float, z: float) -> Node3D:
	var g := Node3D.new()
	g.position = Vector3(x, 0, z)
	var m := mat(Color(0.75, 0.45, 0.25))
	for i in 4:
		var w := 3.4 - i * 0.7
		g.add_child(box(Vector3(w, 1.0, 1.2), m, Vector3(0, 0.5 + i * 1.0, 0)))
	return g

static func barrier(lane_x: float, z: float) -> Node3D:
	var g := Node3D.new()
	g.position = Vector3(lane_x, 0, z)
	var wood := mat(Color(0.55, 0.32, 0.15))
	var red := mat(Color(0.8, 0.15, 0.1))
	var white := mat(Color(0.95, 0.93, 0.88))
	g.add_child(box(Vector3(0.15, 0.8, 0.15), wood, Vector3(-0.8, 0.4, 0)))
	g.add_child(box(Vector3(0.15, 0.8, 0.15), wood, Vector3(0.8, 0.4, 0)))
	g.add_child(box(Vector3(1.9, 0.28, 0.18), red, Vector3(0, 0.62, 0)))
	g.add_child(box(Vector3(0.5, 0.3, 0.2), white, Vector3(-0.35, 0.62, 0)))
	g.add_child(box(Vector3(0.5, 0.3, 0.2), white, Vector3(0.4, 0.62, 0)))
	return g

static func beam(lane_x: float, z: float) -> Node3D:
	var g := Node3D.new()
	g.position = Vector3(lane_x, 0, z)
	var wood := mat(Color(0.5, 0.28, 0.12))
	g.add_child(box(Vector3(0.18, 1.5, 0.18), wood, Vector3(-1.05, 0.75, 0)))
	g.add_child(box(Vector3(0.18, 1.5, 0.18), wood, Vector3(1.05, 0.75, 0)))
	g.add_child(box(Vector3(2.3, 0.45, 0.3), mat(Color(0.85, 0.2, 0.12)), Vector3(0, 1.65, 0)))
	return g

static func lane_pillar(lane_x: float, z: float) -> Node3D:
	var g := Node3D.new()
	g.position = Vector3(lane_x, 0, z)
	var stone := mat(Color(1, 1, 1), "res://assets/textures/sandstone.png", 0.7)
	g.add_child(box(Vector3(1.1, 0.35, 1.1), stone, Vector3(0, 0.175, 0)))
	g.add_child(cyl(0.42, 2.2, stone, Vector3(0, 1.35, 0), 10))
	g.add_child(box(Vector3(1.0, 0.3, 1.0), stone, Vector3(0, 2.6, 0)))
	g.add_child(diya(Vector3(0, 2.8, 0)))
	return g
