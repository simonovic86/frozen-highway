extends Node3D

const CabinInteractableScript := preload("res://scripts/CabinInteractable.gd")

@onready var camera_pivot := $CameraPivot
@onready var camera := $CameraPivot/Camera3D
@onready var interaction_ray := $CameraPivot/Camera3D/InteractionRay

var base_camera_pivot_position := Vector3.ZERO
var resource_state: Node
var radio_system: Node
var truck_controller: Node
var event_manager: Node

var yaw := 0.0
var pitch := 0.0
var mouse_sensitivity := 0.0024
var current_speed := 20.0
var motion_time := 0.0
var storm_visual_intensity := 0.0
var cabin_lights_enabled := true
var next_light_flicker_time := 3.2
var light_flicker_time := 0.0

var hint_label: Label
var radio_label: Label
var speed_label: Label3D
var radio_screen: Label3D
var fuel_needle: Node3D
var heat_needle: Node3D
var engine_needle: Node3D
var warning_light: MeshInstance3D
var heater_glow: MeshInstance3D
var radio_glow: MeshInstance3D
var windshield_snow: MeshInstance3D
var cabin_light: OmniLight3D
var dash_light: OmniLight3D
var hanging_charm: MeshInstance3D
var left_wiper: Node3D
var right_wiper: Node3D

var mat_warm: StandardMaterial3D
var mat_warm_dark: StandardMaterial3D
var mat_warm_emissive: StandardMaterial3D
var mat_dark: StandardMaterial3D
var mat_metal: StandardMaterial3D
var mat_glass: StandardMaterial3D
var mat_red: StandardMaterial3D
var mat_green: StandardMaterial3D
var mat_blue: StandardMaterial3D
var mat_black: StandardMaterial3D
var mat_snow: StandardMaterial3D
var mat_wiper: StandardMaterial3D
var mat_grime: StandardMaterial3D
var mat_rust: StandardMaterial3D
var mat_paper: StandardMaterial3D
var mat_cloth: StandardMaterial3D
var mat_tape: StandardMaterial3D
var mat_wire: StandardMaterial3D

func _ready() -> void:
	base_camera_pivot_position = camera_pivot.position
	_create_materials()
	_build_cabin()
	_build_dashboard()
	_build_personal_objects()
	_build_lights()
	_build_overlay()
	interaction_ray.focus_text_changed.connect(_on_focus_text_changed)

func setup(new_resource_state: Node, new_radio_system: Node, new_truck_controller: Node, new_event_manager: Node) -> void:
	resource_state = new_resource_state
	radio_system = new_radio_system
	truck_controller = new_truck_controller
	event_manager = new_event_manager

	resource_state.changed.connect(_on_resources_changed)
	resource_state.toggles_changed.connect(_on_toggles_changed)
	radio_system.radio_state_changed.connect(_on_radio_state_changed)
	radio_system.message_changed.connect(_on_radio_message_changed)
	truck_controller.speed_changed.connect(_on_speed_changed)

	_on_resources_changed(resource_state.fuel, resource_state.cabin_heat, resource_state.engine_condition)
	_on_toggles_changed(resource_state.heater_on, resource_state.cabin_lights_on)
	_on_radio_state_changed(radio_system.is_on)
	_on_radio_message_changed(radio_system.current_message)

func _process(delta: float) -> void:
	motion_time += delta
	_update_cabin_motion()
	_update_wipers()
	_update_light_flicker(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * mouse_sensitivity
		pitch = clampf(pitch - event.relative.y * mouse_sensitivity, deg_to_rad(-34.0), deg_to_rad(28.0))
		camera_pivot.rotation = Vector3(pitch, yaw, 0.0)

func set_windshield_snow(enabled: bool) -> void:
	storm_visual_intensity = 1.0 if enabled else 0.0
	if windshield_snow != null:
		windshield_snow.visible = enabled

func _on_interactable(action_id: String) -> void:
	match action_id:
		"radio":
			if radio_system != null:
				radio_system.toggle_radio()
		"heater":
			if resource_state != null:
				resource_state.toggle_heater()
		"lights":
			if resource_state != null:
				resource_state.toggle_cabin_lights()

func _on_focus_text_changed(text: String) -> void:
	hint_label.text = text

func _on_resources_changed(fuel: float, cabin_heat: float, engine_condition: float) -> void:
	_set_gauge(fuel_needle, fuel / 100.0)
	_set_gauge(heat_needle, cabin_heat / 100.0)
	_set_gauge(engine_needle, engine_condition / 100.0)
	if warning_light != null:
		warning_light.material_override = mat_red if engine_condition < 45.0 or fuel < 18.0 else mat_green

func _on_toggles_changed(heater_on: bool, cabin_lights_on: bool) -> void:
	cabin_lights_enabled = cabin_lights_on
	if heater_glow != null:
		heater_glow.material_override = mat_red if heater_on else mat_dark
	_apply_light_levels(1.0)

func _on_radio_state_changed(is_on: bool) -> void:
	if radio_glow != null:
		radio_glow.material_override = mat_green if is_on else mat_dark

func _on_radio_message_changed(text: String) -> void:
	if radio_screen != null:
		radio_screen.text = "RADIO\n" + ("SIGNAL" if text != "" else "OFF")
	if radio_label != null:
		radio_label.text = text

func _on_speed_changed(speed: float) -> void:
	current_speed = speed
	if speed_label != null:
		speed_label.text = "%02d KM/H" % int(speed)

func _update_cabin_motion() -> void:
	var speed_factor := clampf(current_speed / 32.0, 0.0, 1.0)
	var storm_factor := storm_visual_intensity
	var shake_strength := 0.006 + speed_factor * 0.012 + storm_factor * 0.012
	camera_pivot.position = base_camera_pivot_position + Vector3(
		sin(motion_time * 7.7) * shake_strength * 0.55,
		sin(motion_time * 11.2) * shake_strength,
		0.0
	)

	if hanging_charm != null:
		hanging_charm.rotation.z = sin(motion_time * 2.6) * (0.12 + storm_factor * 0.12)

func _update_wipers() -> void:
	if left_wiper == null or right_wiper == null:
		return

	var sweeping := storm_visual_intensity > 0.0
	left_wiper.visible = sweeping
	right_wiper.visible = sweeping
	if not sweeping:
		return

	var sweep := (sin(motion_time * 8.0) + 1.0) * 0.5
	var angle := lerpf(deg_to_rad(-42.0), deg_to_rad(34.0), sweep)
	left_wiper.rotation.z = angle
	right_wiper.rotation.z = angle

func _update_light_flicker(delta: float) -> void:
	next_light_flicker_time -= delta
	if next_light_flicker_time <= 0.0:
		light_flicker_time = 0.18 + absf(sin(motion_time * 1.7)) * 0.16
		next_light_flicker_time = 3.6 + absf(sin(motion_time * 0.83)) * 4.8

	var flicker := 1.0
	if light_flicker_time > 0.0:
		light_flicker_time -= delta
		var pulse := absf(sin(motion_time * 82.0))
		flicker = lerpf(0.42, 1.05, pulse)
	_apply_light_levels(flicker)

func _apply_light_levels(flicker: float) -> void:
	var cabin_base := 4.4 if cabin_lights_enabled else 0.35
	var dash_base := 2.8 if cabin_lights_enabled else 0.75
	if cabin_light != null:
		cabin_light.light_energy = cabin_base * flicker
	if dash_light != null:
		dash_light.light_energy = dash_base * lerpf(0.82, 1.0, flicker)

func _set_gauge(needle: Node3D, normalized_value: float) -> void:
	if needle == null:
		return
	var angle := lerpf(deg_to_rad(125.0), deg_to_rad(-125.0), clampf(normalized_value, 0.0, 1.0))
	needle.rotation.z = angle

func _create_materials() -> void:
	mat_warm = _mat(Color(0.5, 0.27, 0.13), Color(0.45, 0.18, 0.04), 0.04)
	mat_warm_dark = _mat(Color(0.15, 0.095, 0.065), Color(0.36, 0.12, 0.03), 0.08)
	mat_warm_emissive = _mat(Color(1.0, 0.58, 0.18), Color(1.0, 0.38, 0.08), 1.8)
	mat_dark = _mat(Color(0.048, 0.042, 0.036), Color(0.08, 0.025, 0.01), 0.025)
	mat_metal = _mat(Color(0.12, 0.115, 0.105), Color.BLACK, 0.0)
	mat_red = _mat(Color(1.0, 0.12, 0.05), Color(1.0, 0.05, 0.0), 1.7)
	mat_green = _mat(Color(0.1, 0.9, 0.38), Color(0.0, 0.8, 0.22), 1.3)
	mat_blue = _mat(Color(0.32, 0.56, 0.8), Color(0.1, 0.32, 0.55), 0.65)
	mat_black = _mat(Color(0.015, 0.014, 0.013), Color.BLACK, 0.0)
	mat_snow = _mat(Color(0.78, 0.86, 0.94), Color(0.18, 0.26, 0.34), 0.15)
	mat_wiper = _mat(Color(0.02, 0.018, 0.016), Color.BLACK, 0.0)
	mat_grime = _mat(Color(0.035, 0.03, 0.024), Color.BLACK, 0.0)
	mat_rust = _mat(Color(0.36, 0.12, 0.045), Color.BLACK, 0.0)
	mat_paper = _mat(Color(0.74, 0.68, 0.52), Color.BLACK, 0.0)
	mat_cloth = _mat(Color(0.18, 0.24, 0.28), Color.BLACK, 0.0)
	mat_tape = _mat(Color(0.58, 0.57, 0.5), Color.BLACK, 0.0)
	mat_wire = _mat(Color(0.02, 0.012, 0.008), Color.BLACK, 0.0)

	mat_glass = StandardMaterial3D.new()
	mat_glass.albedo_color = Color(0.36, 0.62, 0.8, 0.18)
	mat_glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_glass.emission_enabled = true
	mat_glass.emission = Color(0.05, 0.12, 0.18)
	mat_glass.emission_energy_multiplier = 0.3

func _build_cabin() -> void:
	var floor := _add_box(self, "Floor", Vector3(6.8, 0.18, 7.2), Vector3(0.0, -1.0, 1.7), mat_dark)
	floor.rotation_degrees.z = -0.25
	var roof := _add_box(self, "Roof", Vector3(6.8, 0.2, 7.2), Vector3(-0.06, 2.55, 1.74), mat_dark)
	roof.rotation_degrees.z = 0.65
	var left_wall := _add_box(self, "LeftWall", Vector3(0.22, 3.2, 6.6), Vector3(-3.45, 0.55, 1.68), mat_metal)
	left_wall.rotation_degrees.z = -0.35
	var right_wall := _add_box(self, "RightWall", Vector3(0.22, 3.08, 6.45), Vector3(3.39, 0.5, 1.77), mat_metal)
	right_wall.rotation_degrees.z = 0.55
	var back_wall := _add_box(self, "BackWall", Vector3(6.65, 3.2, 0.22), Vector3(-0.08, 0.55, 5.0), mat_dark)
	back_wall.rotation_degrees.y = -0.7
	var dash_bulk := _add_box(self, "DashBulk", Vector3(6.1, 0.9, 0.85), Vector3(0.07, -0.28, -1.36), mat_warm_dark)
	dash_bulk.rotation_degrees.y = -0.8

	_add_box(self, "WindshieldGlass", Vector3(5.3, 1.35, 0.04), Vector3(0.0, 1.25, -1.86), mat_glass)
	var top_frame := _add_box(self, "WindshieldTopFrame", Vector3(5.8, 0.18, 0.18), Vector3(-0.04, 2.04, -1.78), mat_dark)
	top_frame.rotation_degrees.z = 0.45
	var bottom_frame := _add_box(self, "WindshieldBottomFrame", Vector3(5.65, 0.18, 0.18), Vector3(0.06, 0.48, -1.78), mat_dark)
	bottom_frame.rotation_degrees.z = -0.3
	var left_a_frame := _add_box(self, "LeftAFrame", Vector3(0.18, 1.7, 0.18), Vector3(-2.95, 1.25, -1.78), mat_dark)
	left_a_frame.rotation_degrees.z = -1.4
	var right_a_frame := _add_box(self, "RightAFrame", Vector3(0.18, 1.62, 0.18), Vector3(2.91, 1.22, -1.78), mat_dark)
	right_a_frame.rotation_degrees.z = 1.0
	_add_box(self, "LeftSideWindow", Vector3(0.04, 1.0, 1.4), Vector3(-3.34, 1.15, 0.7), mat_glass)
	_add_box(self, "RightSideWindow", Vector3(0.04, 1.0, 1.4), Vector3(3.34, 1.15, 0.7), mat_glass)

	windshield_snow = _add_box(self, "WindshieldSnow", Vector3(5.15, 1.2, 0.035), Vector3(0.0, 1.25, -1.82), mat_snow)
	windshield_snow.visible = false
	_build_wear_marks()
	_build_wipers()

func _build_dashboard() -> void:
	_add_box(self, "AmberDashStrip", Vector3(5.4, 0.08, 0.08), Vector3(0.0, 0.25, -0.86), mat_warm_emissive)
	_build_steering_wheel()

	fuel_needle = _build_gauge("FuelGauge", "FUEL", Vector3(-1.25, 0.18, -0.82))
	heat_needle = _build_gauge("HeatGauge", "HEAT", Vector3(0.0, 0.18, -0.82))
	engine_needle = _build_gauge("EngineGauge", "ENG", Vector3(1.25, 0.18, -0.82))
	speed_label = _add_label3d(self, "SpeedLabel", "20 KM/H", Vector3(0.0, 0.02, -0.76), 34, Color(1.0, 0.58, 0.18))

	var radio := _add_interactable("Radio", "radio", "Toggle radio", Vector3(2.25, -0.22, -0.78), Vector3(0.95, 0.46, 0.22), mat_black)
	radio_glow = _add_box(radio, "RadioGlow", Vector3(0.7, 0.08, 0.025), Vector3(0.0, 0.12, -0.13), mat_green)
	radio_screen = _add_label3d(radio, "RadioScreen", "RADIO", Vector3(0.0, 0.03, -0.145), 20, Color(0.4, 1.0, 0.55))

	var heater := _add_interactable("Heater", "heater", "Toggle heater", Vector3(-2.25, -0.2, -0.78), Vector3(0.75, 0.42, 0.22), mat_black)
	heater_glow = _add_box(heater, "HeaterGlow", Vector3(0.38, 0.1, 0.025), Vector3(0.0, 0.08, -0.13), mat_dark)
	_add_label3d(heater, "HeaterText", "HEAT", Vector3(0.0, -0.04, -0.145), 24, Color(1.0, 0.55, 0.2))

	_add_interactable("LightSwitch", "lights", "Toggle cabin lights", Vector3(2.72, 1.95, 0.75), Vector3(0.28, 0.34, 0.18), mat_warm)
	warning_light = _add_box(self, "WarningLight", Vector3(0.18, 0.18, 0.06), Vector3(1.95, 0.18, -0.76), mat_green)

func _build_steering_wheel() -> void:
	var wheel := MeshInstance3D.new()
	wheel.name = "SteeringWheel"
	var mesh := TorusMesh.new()
	mesh.inner_radius = 0.32
	mesh.outer_radius = 0.43
	wheel.mesh = mesh
	wheel.material_override = mat_black
	wheel.position = Vector3(0.0, -0.08, -0.28)
	wheel.rotation_degrees = Vector3(72.0, 0.0, 0.0)
	add_child(wheel)
	_add_box(self, "SteeringColumn", Vector3(0.16, 0.16, 0.75), Vector3(0.0, -0.42, -0.02), mat_black)

func _build_gauge(name: String, label: String, position: Vector3) -> Node3D:
	var root := Node3D.new()
	root.name = name
	root.position = position
	add_child(root)

	var face_mesh := CylinderMesh.new()
	face_mesh.top_radius = 0.28
	face_mesh.bottom_radius = 0.28
	face_mesh.height = 0.04
	var face := MeshInstance3D.new()
	face.name = "Face"
	face.mesh = face_mesh
	face.material_override = mat_black
	face.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	root.add_child(face)

	_add_label3d(root, "Label", label, Vector3(0.0, -0.39, -0.04), 20, Color(1.0, 0.58, 0.2))

	var needle := Node3D.new()
	needle.name = "NeedlePivot"
	root.add_child(needle)
	_add_box(needle, "Needle", Vector3(0.035, 0.24, 0.035), Vector3(0.0, 0.11, -0.045), mat_warm_emissive)
	return needle

func _build_personal_objects() -> void:
	var blanket := _add_box(self, "Blanket", Vector3(1.4, 0.18, 1.0), Vector3(-2.1, -0.86, 3.6), mat_cloth)
	blanket.rotation_degrees.y = -6.0
	_add_box(self, "BlanketFold", Vector3(1.15, 0.16, 0.28), Vector3(-2.22, -0.7, 3.18), mat_warm)
	_add_box(self, "OldPhoto", Vector3(0.55, 0.36, 0.04), Vector3(-1.95, 0.55, -0.76), mat_blue)
	_add_box(self, "PhotoBorder", Vector3(0.65, 0.45, 0.025), Vector3(-1.95, 0.55, -0.79), mat_paper)
	var tin_cup := _add_box(self, "TinCup", Vector3(0.28, 0.34, 0.28), Vector3(1.9, -0.64, -0.35), mat_metal)
	tin_cup.rotation_degrees.z = 7.0
	_add_box(self, "Thermos", Vector3(0.24, 0.58, 0.24), Vector3(2.55, -0.54, 0.18), mat_blue)
	_add_box(self, "ThermosCap", Vector3(0.2, 0.1, 0.2), Vector3(2.55, -0.2, 0.18), mat_metal)
	_add_box(self, "Toolbox", Vector3(0.95, 0.42, 0.48), Vector3(-2.35, -0.69, 1.05), mat_rust)
	_add_box(self, "ToolboxLatch", Vector3(0.24, 0.08, 0.04), Vector3(-2.35, -0.48, 0.8), mat_metal)
	var wrench := _add_box(self, "LooseWrench", Vector3(0.68, 0.06, 0.09), Vector3(-1.55, -0.86, 1.22), mat_metal)
	wrench.rotation_degrees.y = 22.0
	_add_box(self, "WrenchHead", Vector3(0.2, 0.08, 0.16), Vector3(-1.24, -0.85, 1.35), mat_metal)
	var map := _add_box(self, "FoldedMap", Vector3(0.86, 0.02, 0.58), Vector3(0.9, -0.72, 0.9), mat_paper)
	map.rotation_degrees.y = -18.0
	_add_box(self, "MapCrease", Vector3(0.035, 0.025, 0.6), Vector3(0.92, -0.7, 0.9), mat_grime)
	_add_box(self, "FoodCanA", Vector3(0.22, 0.24, 0.22), Vector3(2.85, -0.76, 1.15), mat_metal)
	_add_box(self, "FoodCanB", Vector3(0.2, 0.2, 0.2), Vector3(2.55, -0.78, 1.32), mat_rust)
	_add_box(self, "GloveLeft", Vector3(0.52, 0.12, 0.26), Vector3(-0.72, -0.84, 2.86), mat_warm_dark)
	var glove_right := _add_box(self, "GloveRight", Vector3(0.5, 0.12, 0.26), Vector3(-0.2, -0.84, 2.98), mat_warm_dark)
	glove_right.rotation_degrees.y = 16.0
	_build_story_note()
	_build_improvised_fix()
	hanging_charm = _add_box(self, "HangingCharm", Vector3(0.12, 0.26, 0.04), Vector3(0.45, 1.82, -1.62), mat_warm_emissive)

func _build_story_note() -> void:
	var note := _add_box(self, "FuelDebtNote", Vector3(0.62, 0.42, 0.025), Vector3(-2.56, 0.18, -0.82), mat_paper)
	note.rotation_degrees.z = -4.0
	var note_text := _add_label3d(self, "FuelDebtNoteText", "MARA\n2 CANS\nOWED", Vector3(-2.56, 0.18, -0.845), 18, Color(0.08, 0.07, 0.055))
	note_text.rotation_degrees.z = -4.0
	_add_box(self, "NotePin", Vector3(0.09, 0.09, 0.025), Vector3(-2.56, 0.38, -0.86), mat_rust)

func _build_improvised_fix() -> void:
	var tape_a := _add_box(self, "CrackedFrameTapeA", Vector3(0.72, 0.09, 0.035), Vector3(2.42, 1.82, -1.82), mat_tape)
	tape_a.rotation_degrees.z = 36.0
	var tape_b := _add_box(self, "CrackedFrameTapeB", Vector3(0.62, 0.085, 0.035), Vector3(2.55, 1.7, -1.82), mat_tape)
	tape_b.rotation_degrees.z = -28.0
	var wire_a := _add_box(self, "ExposedWireA", Vector3(0.045, 0.62, 0.045), Vector3(2.85, 1.46, -1.72), mat_wire)
	wire_a.rotation_degrees.z = -14.0
	var wire_b := _add_box(self, "ExposedWireB", Vector3(0.04, 0.5, 0.04), Vector3(2.72, 1.21, -1.71), mat_wire)
	wire_b.rotation_degrees.z = 22.0
	_add_box(self, "WireCopperEnd", Vector3(0.06, 0.08, 0.045), Vector3(2.62, 0.98, -1.71), mat_rust)

func _build_wear_marks() -> void:
	var dash_stain := _add_box(self, "DashCoffeeStain", Vector3(0.62, 0.035, 0.34), Vector3(1.72, -0.78, -0.88), mat_grime)
	dash_stain.rotation_degrees.y = -9.0
	var dash_scrape := _add_box(self, "DashScrape", Vector3(1.35, 0.045, 0.055), Vector3(-0.95, 0.24, -0.91), mat_rust)
	dash_scrape.rotation_degrees.z = 1.5
	_add_box(self, "LeftFloorGrime", Vector3(1.65, 0.035, 1.2), Vector3(-1.1, -0.88, 2.0), mat_grime)
	_add_box(self, "RightFloorGrime", Vector3(1.1, 0.035, 0.92), Vector3(1.65, -0.88, 2.45), mat_grime)
	var windshield_smear := _add_box(self, "WindshieldSmear", Vector3(1.5, 0.32, 0.025), Vector3(-1.15, 1.36, -1.835), mat_grime)
	windshield_smear.rotation_degrees.z = -8.0
	var right_wall_rust := _add_box(self, "RightWallRustBloom", Vector3(0.026, 0.78, 1.05), Vector3(3.25, 0.05, 2.8), mat_rust)
	right_wall_rust.rotation_degrees.z = 2.0
	var left_wall_scratches := _add_box(self, "LeftWallScratches", Vector3(0.026, 1.1, 0.08), Vector3(-3.28, 0.42, 1.2), mat_grime)
	left_wall_scratches.rotation_degrees.x = 12.0
	_add_box(self, "UnevenRoofGrime", Vector3(1.4, 0.035, 0.82), Vector3(-1.75, 2.42, 2.75), mat_grime)

func _build_wipers() -> void:
	left_wiper = _build_wiper("LeftWiper", Vector3(-1.7, 0.52, -1.78))
	right_wiper = _build_wiper("RightWiper", Vector3(1.7, 0.52, -1.78))
	left_wiper.visible = false
	right_wiper.visible = false

func _build_wiper(name: String, position: Vector3) -> Node3D:
	var root := Node3D.new()
	root.name = name
	root.position = position
	add_child(root)

	_add_box(root, "Arm", Vector3(0.07, 1.15, 0.035), Vector3(0.0, 0.52, 0.0), mat_wiper)
	_add_box(root, "Blade", Vector3(0.11, 0.18, 0.045), Vector3(0.0, 1.08, 0.0), mat_wiper)
	return root

func _build_lights() -> void:
	cabin_light = OmniLight3D.new()
	cabin_light.name = "CabinWarmLight"
	cabin_light.light_color = Color(1.0, 0.58, 0.24)
	cabin_light.light_energy = 4.4
	cabin_light.omni_range = 6.0
	cabin_light.position = Vector3(0.0, 2.12, 1.7)
	add_child(cabin_light)

	dash_light = OmniLight3D.new()
	dash_light.name = "DashAmberLight"
	dash_light.light_color = Color(1.0, 0.42, 0.1)
	dash_light.light_energy = 2.8
	dash_light.omni_range = 4.0
	dash_light.position = Vector3(0.0, 0.3, -0.62)
	add_child(dash_light)

func _build_overlay() -> void:
	var layer := CanvasLayer.new()
	layer.name = "CabinOverlay"
	add_child(layer)

	hint_label = Label.new()
	hint_label.name = "HintLabel"
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint_label.anchor_left = 0.3
	hint_label.anchor_right = 0.7
	hint_label.anchor_top = 0.82
	hint_label.anchor_bottom = 0.9
	hint_label.add_theme_font_size_override("font_size", 22)
	layer.add_child(hint_label)

	radio_label = Label.new()
	radio_label.name = "RadioCaption"
	radio_label.anchor_left = 0.04
	radio_label.anchor_right = 0.62
	radio_label.anchor_top = 0.04
	radio_label.anchor_bottom = 0.16
	radio_label.add_theme_font_size_override("font_size", 20)
	radio_label.modulate = Color(0.6, 1.0, 0.7)
	layer.add_child(radio_label)

func _add_interactable(name: String, action_id: String, label: String, position: Vector3, size: Vector3, material: Material) -> StaticBody3D:
	var body: StaticBody3D = CabinInteractableScript.new()
	body.name = name
	body.setup(action_id, label)
	body.position = position
	body.interacted.connect(_on_interactable)
	add_child(body)

	_add_box(body, "Mesh", size, Vector3.ZERO, material)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	return body

func _add_box(parent: Node, name: String, size: Vector3, position: Vector3, material: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.name = name
	instance.mesh = mesh
	instance.material_override = material
	instance.position = position
	parent.add_child(instance)
	return instance

func _add_label3d(parent: Node, name: String, text: String, position: Vector3, size: int, color: Color) -> Label3D:
	var label := Label3D.new()
	label.name = name
	label.text = text
	label.font_size = size
	label.modulate = color
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	label.position = position
	parent.add_child(label)
	return label

func _mat(color: Color, emission: Color, emission_energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.88
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = emission_energy
	return material
