class_name Hud
extends CanvasLayer

signal play_pressed
signal restart_pressed
signal menu_pressed
signal pause_pressed
signal char_prev
signal char_next

var hud_root: Control
var score_label: Label
var coin_label: Label
var dist_label: Label
var menu_root: Control
var char_name: Label
var char_desc: Label
var char_cost: Label
var best_label: Label
var coins_label: Label
var go_root: Control
var go_score: Label
var go_best: Label
var go_coins: Label
var go_newbest: Label
var pause_overlay: Control

const SAFFRON := Color(0.96, 0.55, 0.08)
const DARK := Color(0.12, 0.07, 0.14)
const CREAM := Color(1.0, 0.95, 0.85)

func _ready() -> void:
	layer = 10
	_build_hud()
	_build_menu()
	_build_gameover()
	_build_pause()

func _label(text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l

func _style(bg: Color, radius: int, border := Color(0, 0, 0, 0), border_w := 0) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_left = radius
	sb.corner_radius_bottom_right = radius
	if border_w > 0:
		sb.border_color = border
		sb.set_border_width_all(border_w)
	sb.content_margin_left = 28
	sb.content_margin_right = 28
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	return sb

func _button(text: String, size: int) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", size)
	b.add_theme_color_override("font_color", Color(0.2, 0.1, 0.02))
	b.add_theme_stylebox_override("normal", _style(SAFFRON, 14))
	b.add_theme_stylebox_override("hover", _style(Color(1.0, 0.68, 0.2), 14))
	b.add_theme_stylebox_override("pressed", _style(Color(0.8, 0.42, 0.05), 14))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	return b

func _panel() -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", _style(Color(0.12, 0.07, 0.14, 0.94), 24, SAFFRON, 4))
	return p

func _build_hud() -> void:
	hud_root = Control.new()
	hud_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(hud_root)
	var bar := HBoxContainer.new()
	bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	bar.offset_left = 16
	bar.offset_right = -16
	bar.offset_top = 8
	bar.custom_minimum_size.y = 64
	bar.add_theme_constant_override("separation", 16)
	hud_root.add_child(bar)
	var left := HBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 8)
	bar.add_child(left)
	var icon := TextureRect.new()
	icon.texture = load("res://assets/textures/coin_icon.png")
	icon.custom_minimum_size = Vector2(40, 40)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	left.add_child(icon)
	coin_label = _label("x 0", 30, CREAM)
	left.add_child(coin_label)
	score_label = _label("0", 44, CREAM)
	score_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bar.add_child(score_label)
	var right := HBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.alignment = BoxContainer.ALIGNMENT_END
	bar.add_child(right)
	dist_label = _label("0 m", 26, CREAM)
	right.add_child(dist_label)
	var pause_btn := _button("II", 26)
	pause_btn.custom_minimum_size = Vector2(64, 56)
	pause_btn.pressed.connect(func(): emit_signal("pause_pressed"))
	right.add_child(pause_btn)
	hud_root.visible = false

func _build_menu() -> void:
	menu_root = Control.new()
	menu_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(menu_root)
	var bg := ColorRect.new()
	bg.color = Color(0.1, 0.06, 0.14, 0.88)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu_root.add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu_root.add_child(center)
	var panel := _panel()
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 48)
	margin.add_theme_constant_override("margin_right", 48)
	margin.add_theme_constant_override("margin_top", 36)
	margin.add_theme_constant_override("margin_bottom", 36)
	panel.add_child(margin)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vbox)
	var title := _label("TEMPLE RUN INDIA", 58, SAFFRON)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	var sub := _label("Run through the temples of India!", 24, CREAM)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sub)
	var char_row := HBoxContainer.new()
	char_row.alignment = BoxContainer.ALIGNMENT_CENTER
	char_row.add_theme_constant_override("separation", 20)
	vbox.add_child(char_row)
	var prev := _button("<", 34)
	prev.pressed.connect(func(): emit_signal("char_prev"))
	char_row.add_child(prev)
	var char_box := VBoxContainer.new()
	char_box.custom_minimum_size.x = 320
	char_box.alignment = BoxContainer.ALIGNMENT_CENTER
	char_row.add_child(char_box)
	char_name = _label("Veer", 36, CREAM)
	char_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	char_box.add_child(char_name)
	char_desc = _label("The Warrior", 22, Color(0.85, 0.75, 0.6))
	char_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	char_box.add_child(char_desc)
	char_cost = _label("", 20, SAFFRON)
	char_cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	char_box.add_child(char_cost)
	var next := _button(">", 34)
	next.pressed.connect(func(): emit_signal("char_next"))
	char_row.add_child(next)
	var play := _button("PLAY", 40)
	play.custom_minimum_size = Vector2(320, 76)
	play.pressed.connect(func(): emit_signal("play_pressed"))
	vbox.add_child(play)
	var stats := HBoxContainer.new()
	stats.alignment = BoxContainer.ALIGNMENT_CENTER
	stats.add_theme_constant_override("separation", 60)
	vbox.add_child(stats)
	best_label = _label("Best: 0", 24, CREAM)
	stats.add_child(best_label)
	coins_label = _label("Coins: 0", 24, SAFFRON)
	stats.add_child(coins_label)
	var hint := _label("Swipe / Arrow keys: switch lane   |   Up / Space: jump   |   Down: slide   |   Esc: pause", 18, Color(0.75, 0.7, 0.65))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(hint)

func _build_gameover() -> void:
	go_root = Control.new()
	go_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	go_root.visible = false
	add_child(go_root)
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.04, 0.1, 0.8)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	go_root.add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	go_root.add_child(center)
	var panel := _panel()
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 56)
	margin.add_theme_constant_override("margin_right", 56)
	margin.add_theme_constant_override("margin_top", 32)
	margin.add_theme_constant_override("margin_bottom", 32)
	panel.add_child(margin)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vbox)
	var t := _label("GAME OVER", 54, Color(0.95, 0.35, 0.2))
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(t)
	go_newbest = _label("NEW BEST!", 28, SAFFRON)
	go_newbest.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(go_newbest)
	go_score = _label("Score: 0", 34, CREAM)
	go_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(go_score)
	go_best = _label("Best: 0", 24, CREAM)
	go_best.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(go_best)
	go_coins = _label("Coins: 0", 24, SAFFRON)
	go_coins.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(go_coins)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	vbox.add_child(row)
	var restart := _button("RESTART", 30)
	restart.custom_minimum_size = Vector2(220, 64)
	restart.pressed.connect(func(): emit_signal("restart_pressed"))
	row.add_child(restart)
	var menu := _button("MENU", 30)
	menu.custom_minimum_size = Vector2(220, 64)
	menu.add_theme_stylebox_override("normal", _style(Color(0.4, 0.25, 0.5, 0.95), 14))
	menu.add_theme_stylebox_override("hover", _style(Color(0.5, 0.32, 0.6, 0.95), 14))
	menu.add_theme_stylebox_override("pressed", _style(Color(0.3, 0.18, 0.4, 0.95), 14))
	menu.pressed.connect(func(): emit_signal("menu_pressed"))
	row.add_child(menu)

func _build_pause() -> void:
	pause_overlay = Control.new()
	pause_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_overlay.visible = false
	add_child(pause_overlay)
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.55)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_overlay.add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_overlay.add_child(center)
	var l := _label("PAUSED", 56, CREAM)
	center.add_child(l)

func show_menu(data: Dictionary, chars: Array) -> void:
	menu_root.visible = true
	hud_root.visible = false
	go_root.visible = false
	pause_overlay.visible = false
	best_label.text = "Best: %d" % int(data.get("best", 0))
	coins_label.text = "Coins: %d" % int(data.get("coins", 0))

func set_char(ch: Dictionary, unlocked: bool) -> void:
	char_name.text = ch.name
	char_desc.text = ch.desc
	if unlocked:
		char_cost.text = "Unlocked"
	else:
		char_cost.text = "Locked - %d coins" % int(ch.cost)

func show_hud() -> void:
	menu_root.visible = false
	go_root.visible = false
	pause_overlay.visible = false
	hud_root.visible = true

func show_gameover(score: int, best: int, coins: int, new_best: bool) -> void:
	hud_root.visible = false
	menu_root.visible = false
	pause_overlay.visible = false
	go_root.visible = true
	go_score.text = "Score: %d" % score
	go_best.text = "Best: %d" % best
	go_coins.text = "Coins this run: %d" % coins
	go_newbest.visible = new_best

func set_score(s: int) -> void:
	score_label.text = str(s)

func set_coins(c: int) -> void:
	coin_label.text = "x %d" % c

func set_distance(d: int) -> void:
	dist_label.text = "%d m" % d

func set_paused(b: bool) -> void:
	pause_overlay.visible = b
