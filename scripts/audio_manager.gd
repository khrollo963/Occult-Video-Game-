extends Node

## Procedural SFX/music scaffold. Set to true when real audio assets are wired up.
const AUDIO_ENABLED := false

const SFX := {
	"ui_click": {"freq": 880.0, "duration": 0.06, "volume": -8.0},
	"jump": {"freq": 520.0, "duration": 0.08, "volume": -10.0},
	"hit": {"freq": 180.0, "duration": 0.12, "volume": -6.0},
	"pickup": {"freq": 660.0, "duration": 0.1, "volume": -8.0},
	"death": {"freq": 120.0, "duration": 0.35, "volume": -4.0},
	"level_complete": {"freq": 740.0, "duration": 0.25, "volume": -6.0},
	"new_high_score": {"freq": 990.0, "duration": 0.3, "volume": -5.0},
}

var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_index := 0


func _ready() -> void:
	_setup_buses()
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	_music_player.volume_db = -14.0
	add_child(_music_player)
	for i in 4:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_sfx_players.append(player)
	if not AUDIO_ENABLED:
		return
	get_node("/root/EventBus").player_damaged.connect(func(_a): play_sfx("hit"))
	get_node("/root/EventBus").collectible_picked.connect(func(_v): play_sfx("pickup"))
	get_node("/root/EventBus").enemy_killed.connect(func(): play_sfx("hit"))
	get_node("/root/EventBus").new_high_score.connect(func(_g, _s): play_sfx("new_high_score"))


func _setup_buses() -> void:
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, "Music")
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, "SFX")
	if AudioServer.get_bus_index("UI") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, "UI")
	var master := AudioServer.get_bus_index("Master")
	var music_idx := AudioServer.get_bus_index("Music")
	var sfx_idx := AudioServer.get_bus_index("SFX")
	var ui_idx := AudioServer.get_bus_index("UI")
	if music_idx >= 0:
		AudioServer.set_bus_send(music_idx, "Master")
	if sfx_idx >= 0:
		AudioServer.set_bus_send(sfx_idx, "Master")
	if ui_idx >= 0:
		AudioServer.set_bus_send(ui_idx, "Master")


func play_sfx(id: String) -> void:
	if not AUDIO_ENABLED:
		return
	if not SFX.has(id):
		return
	var spec: Dictionary = SFX[id]
	var stream := _make_tone(spec.freq, spec.duration)
	var player := _sfx_players[_sfx_index]
	_sfx_index = (_sfx_index + 1) % _sfx_players.size()
	player.stream = stream
	player.volume_db = spec.volume
	player.pitch_scale = randf_range(0.95, 1.05)
	player.play()


func play_ui_click() -> void:
	play_sfx("ui_click")


func play_music(_track_id := "menu") -> void:
	if not AUDIO_ENABLED:
		return
	if _music_player.playing:
		return
	_music_player.stream = _make_tone(220.0, 4.0, true)
	_music_player.play()


func duck_music() -> void:
	if not AUDIO_ENABLED:
		return
	var tween := create_tween()
	tween.tween_property(_music_player, "volume_db", -22.0, 0.15)
	tween.tween_property(_music_player, "volume_db", -14.0, 0.4)


func _make_tone(freq: float, duration: float, loop := false) -> AudioStreamWAV:
	var sample_rate := 22050
	var sample_count := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(sample_count)
	for i in sample_count:
		var t := float(i) / float(sample_rate)
		var envelope := 1.0 - (float(i) / float(sample_count))
		var sample := sin(TAU * freq * t) * envelope
		data[i] = int(clampi(int(sample * 127.0) + 128, 0, 255))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED
	return stream
