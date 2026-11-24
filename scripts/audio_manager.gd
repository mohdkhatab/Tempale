class_name AudioManager
extends Node

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var _next := 0

const SFX := {
	"coin": "res://assets/audio/handleCoins.ogg",
	"coin2": "res://assets/audio/chipLay1.ogg",
	"jump": "res://assets/audio/phaseJump1.ogg",
	"slide": "res://assets/audio/cloth1.ogg",
	"hit": "res://assets/audio/chop.ogg",
	"step": "res://assets/audio/footstep00.ogg",
	"click": "res://assets/audio/click1.ogg",
	"gameover": "res://assets/audio/lowDown.ogg",
	"jingle": "res://assets/audio/jingles_PIZZA00.ogg",
}

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "Music"
	music_player.volume_db = -8.0
	add_child(music_player)
	var wav: AudioStreamWAV = load("res://assets/audio/music.wav")
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_end = wav.get_data().size() / 2
	music_player.stream = wav
	for i in 6:
		var p := AudioStreamPlayer.new()
		add_child(p)
		sfx_players.append(p)

func play_music() -> void:
	if not music_player.playing:
		music_player.play()

func sfx(name: String) -> void:
	if not SFX.has(name):
		return
	var p := sfx_players[_next]
	_next = (_next + 1) % sfx_players.size()
	p.stream = load(SFX[name])
	p.play()
