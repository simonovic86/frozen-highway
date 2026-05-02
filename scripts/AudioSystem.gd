class_name AudioSystem
extends Node

const MIX_RATE := 22050.0
const TWO_PI := PI * 2.0

var resource_state: Node
var radio_system: Node
var truck_controller: Node

var engine_player: AudioStreamPlayer
var wind_player: AudioStreamPlayer
var radio_player: AudioStreamPlayer

var engine_playback: AudioStreamGeneratorPlayback
var wind_playback: AudioStreamGeneratorPlayback
var radio_playback: AudioStreamGeneratorPlayback

var engine_phase := 0.0
var wind_phase := 0.0
var radio_noise := 0.37

var speed := 20.0
var storm_intensity := 0.0
var radio_on := true
var radio_burst_timer := 0.0

func setup(new_resource_state: Node, new_radio_system: Node, new_truck_controller: Node, event_manager: Node) -> void:
	resource_state = new_resource_state
	radio_system = new_radio_system
	truck_controller = new_truck_controller

	_build_players()

	if truck_controller != null:
		truck_controller.speed_changed.connect(_on_speed_changed)
	if radio_system != null:
		radio_system.radio_state_changed.connect(_on_radio_state_changed)
		radio_on = radio_system.is_on
	if event_manager != null:
		event_manager.event_started.connect(_on_event_started)

func _process(_delta: float) -> void:
	if radio_burst_timer > 0.0:
		radio_burst_timer = maxf(0.0, radio_burst_timer - _delta)
	if resource_state != null:
		storm_intensity = resource_state.storm_intensity
	_fill_engine()
	_fill_wind()
	_fill_radio()

func _build_players() -> void:
	engine_player = _make_generator_player("EngineRumble", -17.0)
	wind_player = _make_generator_player("WindHiss", -24.0)
	radio_player = _make_generator_player("RadioStatic", -22.0)

	engine_playback = engine_player.get_stream_playback() as AudioStreamGeneratorPlayback
	wind_playback = wind_player.get_stream_playback() as AudioStreamGeneratorPlayback
	radio_playback = radio_player.get_stream_playback() as AudioStreamGeneratorPlayback

func _make_generator_player(player_name: String, volume_db: float) -> AudioStreamPlayer:
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = MIX_RATE
	stream.buffer_length = 0.18

	var player := AudioStreamPlayer.new()
	player.name = player_name
	player.stream = stream
	player.volume_db = volume_db
	add_child(player)
	player.play()
	return player

func _fill_engine() -> void:
	if engine_playback == null:
		return

	var target_frequency := lerpf(34.0, 58.0, clampf(speed / 32.0, 0.0, 1.0))
	var amplitude := lerpf(0.08, 0.16, clampf(speed / 32.0, 0.0, 1.0))
	for i in engine_playback.get_frames_available():
		var low := sin(engine_phase) * amplitude
		var mid := sin(engine_phase * 2.03) * amplitude * 0.35
		var sample := low + mid
		engine_phase = fmod(engine_phase + TWO_PI * target_frequency / MIX_RATE, TWO_PI)
		engine_playback.push_frame(Vector2(sample, sample))

func _fill_wind() -> void:
	if wind_playback == null:
		return

	var wind_level := lerpf(0.025, 0.11, storm_intensity)
	var wobble_rate := lerpf(0.7, 1.6, storm_intensity)
	for i in wind_playback.get_frames_available():
		var noise := _next_noise()
		var wobble := (sin(wind_phase) + 1.0) * 0.5
		var sample := noise * wind_level * lerpf(0.35, 1.0, wobble)
		wind_phase = fmod(wind_phase + TWO_PI * wobble_rate / MIX_RATE, TWO_PI)
		wind_playback.push_frame(Vector2(sample, sample))

func _fill_radio() -> void:
	if radio_playback == null:
		return

	var amplitude := 0.055 if radio_on else 0.0
	if radio_burst_timer > 0.0:
		amplitude = 0.18
	for i in radio_playback.get_frames_available():
		var sample := _next_noise() * amplitude
		radio_playback.push_frame(Vector2(sample, sample))

func _next_noise() -> float:
	radio_noise = fmod(radio_noise * 12.9898 + 78.233, 1.0)
	return radio_noise * 2.0 - 1.0

func _on_speed_changed(new_speed: float) -> void:
	speed = new_speed

func _on_radio_state_changed(is_on: bool) -> void:
	radio_on = is_on

func _on_event_started(kind: String) -> void:
	if kind == "opening_radio_crackle":
		radio_burst_timer = 1.2
	if kind == "snowstorm" and wind_player != null:
		wind_player.volume_db = -18.0
	elif wind_player != null:
		wind_player.volume_db = -24.0
