extends Node3D

const ResourceStateScript := preload("res://scripts/ResourceState.gd")
const TruckControllerScript := preload("res://scripts/TruckController.gd")
const RadioSystemScript := preload("res://scripts/RadioSystem.gd")
const EventManagerScript := preload("res://scripts/EventManager.gd")
const AudioSystemScript := preload("res://scripts/AudioSystem.gd")

@onready var cabin := $Cabin
@onready var road := $Road
@onready var world_environment := $WorldEnvironment

var resource_state: Node
var truck_controller: Node
var radio_system: Node
var event_manager: Node
var audio_system: Node
var pause_overlay: CanvasLayer
var pause_label: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	cabin.process_mode = Node.PROCESS_MODE_PAUSABLE
	road.process_mode = Node.PROCESS_MODE_PAUSABLE
	_ensure_input_actions()
	_setup_environment()
	_build_pause_overlay()

	resource_state = ResourceStateScript.new()
	truck_controller = TruckControllerScript.new()
	radio_system = RadioSystemScript.new()
	event_manager = EventManagerScript.new()
	audio_system = AudioSystemScript.new()
	resource_state.process_mode = Node.PROCESS_MODE_PAUSABLE
	truck_controller.process_mode = Node.PROCESS_MODE_PAUSABLE
	radio_system.process_mode = Node.PROCESS_MODE_PAUSABLE
	event_manager.process_mode = Node.PROCESS_MODE_PAUSABLE
	audio_system.process_mode = Node.PROCESS_MODE_PAUSABLE

	add_child(resource_state)
	add_child(truck_controller)
	add_child(radio_system)
	add_child(event_manager)
	add_child(audio_system)

	truck_controller.resource_state = resource_state
	truck_controller.speed_changed.connect(road.set_drive_speed)

	cabin.setup(resource_state, radio_system, truck_controller, event_manager)
	event_manager.setup(resource_state, radio_system, road, cabin)
	audio_system.setup(resource_state, radio_system, truck_controller, event_manager)

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("release_mouse"):
		_set_paused(not get_tree().paused)
		get_viewport().set_input_as_handled()
	if get_tree().paused:
		return
	if event.is_action_pressed("radio_toggle") and radio_system != null:
		radio_system.toggle_radio()
	if event.is_action_pressed("heater_toggle") and resource_state != null:
		resource_state.toggle_heater()
	if event.is_action_pressed("lights_toggle") and resource_state != null:
		resource_state.toggle_cabin_lights()

func _setup_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.012, 0.022, 0.038)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.08, 0.13, 0.18)
	environment.ambient_light_energy = 0.35
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.36, 0.48, 0.62)
	environment.fog_density = 0.045
	world_environment.environment = environment

	var cold_moon := DirectionalLight3D.new()
	cold_moon.name = "ColdMoonLight"
	cold_moon.light_color = Color(0.55, 0.68, 0.9)
	cold_moon.light_energy = 0.45
	cold_moon.rotation_degrees = Vector3(-45.0, 20.0, 0.0)
	add_child(cold_moon)

func _build_pause_overlay() -> void:
	pause_overlay = CanvasLayer.new()
	pause_overlay.name = "PauseOverlay"
	pause_overlay.visible = false
	add_child(pause_overlay)

	var panel := ColorRect.new()
	panel.name = "PauseScrim"
	panel.color = Color(0.0, 0.0, 0.0, 0.45)
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	pause_overlay.add_child(panel)

	pause_label = Label.new()
	pause_label.name = "PauseLabel"
	pause_label.text = "PAUSED\nEsc to return"
	pause_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pause_label.anchor_left = 0.38
	pause_label.anchor_right = 0.62
	pause_label.anchor_top = 0.42
	pause_label.anchor_bottom = 0.58
	pause_label.add_theme_font_size_override("font_size", 28)
	pause_overlay.add_child(pause_label)

func _set_paused(enabled: bool) -> void:
	get_tree().paused = enabled
	if pause_overlay != null:
		pause_overlay.visible = enabled
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if enabled else Input.MOUSE_MODE_CAPTURED)

func _ensure_input_actions() -> void:
	_add_key_action("interact", KEY_E)
	_add_key_action("radio_toggle", KEY_R)
	_add_key_action("heater_toggle", KEY_H)
	_add_key_action("lights_toggle", KEY_L)
	_add_key_action("throttle_up", KEY_W)
	_add_key_action("throttle_down", KEY_S)
	_add_key_action("release_mouse", KEY_ESCAPE)

func _add_key_action(action_name: String, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	var event := InputEventKey.new()
	event.keycode = keycode
	for existing_event in InputMap.action_get_events(action_name):
		if existing_event is InputEventKey and existing_event.keycode == keycode:
			return
	InputMap.action_add_event(action_name, event)
