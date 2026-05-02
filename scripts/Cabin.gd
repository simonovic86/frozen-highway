extends Node3D

const CabinInteractableScript := preload("res://scripts/CabinInteractable.gd")

@onready var camera_pivot := $CameraPivot
@onready var camera := $CameraPivot/Camera3D
@onready var interaction_ray := $CameraPivot/Camera3D/InteractionRay

var resource_state: Node
var radio_system: Node
var truck_controller: Node
var event_manager: Node

var yaw := 0.0
var pitch := 0.0
var mouse_sensitivity := 0.0024

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

func _ready() -> void:
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

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * mouse_sensitivity
		pitch = clampf(pitch - event.relative.y * mouse_sensitivity, deg_to_rad(-34.0), deg_to_rad(28.0))
		camera_pivot.rotation = Vector3(pitch, yaw, 0.0)

func set_windshield_snow(enabled: bool) -> void:
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
	if heater_glow != null:
		heater_glow.material_override = mat_red if heater_on else mat_dark
	if cabin_light != null:
		cabin_light.light_energy = 4.4 if cabin_lights_on else 0.35
	if dash_light != null:
		dash_light.light_energy = 2.8 if cabin_lights_on else 0.75

func _on_radio_state_changed(is_on: bool) -> void:
	if radio_glow != null:
		radio_glow.material_override = mat_green if is_on else mat_dark

func _on_radio_message_changed(text: String) -> void:
	if radio_screen != null:
		radio_screen.text = "RADIO\n" + ("SIGNAL" if text != "" else "OFF")
	if radio_label != null:
		radio_label.text = text

func _on_speed_changed(speed: float) -> void:
	if speed_label != null:
		speed_label.text = "%02d KM/H" % int(speed)

func _set_gauge(needle: Node3D, normalized_value: float) -> void:
	if needle == null:
		return
	var angle := lerpf(deg_to_rad(125.0), deg_to_rad(-125.0), clampf(normalized_value, 0.0, 1.0))
	needle.rotation.z = angle

func _create_materials() -> void:
	mat_warm = _mat(Color(0.78, 0.42, 0.18), Color(0.8, 0.32, 0.07), 0.08)
	mat_warm_dark = _mat(Color(0.22, 0.13, 0.08), Color(0.55, 0.18, 0.05), 0.18)
	mat_warm_emissive = _mat(Color(1.0, 0.58, 0.18), Color(1.0, 0.38, 0.08), 1.8)
	mat_dark = _mat(Color(0.075, 0.055, 0.045), Color(0.15, 0.05, 0.015), 0.04)
	mat_metal = _mat(Color(0.18, 0.17, 0.16), Color.BLACK, 0.0)
	mat_red = _mat(Color(1.0, 0.12, 0.05), Color(1.0, 0.05, 0.0), 1.7)
	mat_green = _mat(Color(0.1, 0.9, 0.38), Color(0.0, 0.8, 0.22), 1.3)
	mat_blue = _mat(Color(0.32, 0.56, 0.8), Color(0.1, 0.32, 0.55), 0.65)
	mat_black = _mat(Color(0.015, 0.014, 0.013), Color.BLACK, 0.0)
	mat_snow = _mat(Color(0.78, 0.86, 0.94), Color(0.18, 0.26, 0.34), 0.15)

	mat_glass = StandardMaterial3D.new()
	mat_glass.albedo_color = Color(0.36, 0.62, 0.8, 0.18)
	mat_glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_glass.emission_enabled = true
	mat_glass.emission = Color(0.05, 0.12, 0.18)
	mat_glass.emission_energy_multiplier = 0.3

func _build_cabin() -> void:
	_add_box(self, "Floor", Vector3(6.8, 0.18, 7.2), Vector3(0.0, -1.0, 1.7), mat_dark)
	_add_box(self, "Roof", Vector3(6.8, 0.2, 7.2), Vector3(0.0, 2.55, 1.7), mat_dark)
	_add_box(self, "LeftWall", Vector3(0.22, 3.2, 6.6), Vector3(-3.45, 0.55, 1.7), mat_metal)
	_add_box(self, "RightWall", Vector3(0.22, 3.2, 6.6), Vector3(3.45, 0.55, 1.7), mat_metal)
	_add_box(self, "BackWall", Vector3(6.8, 3.2, 0.22), Vector3(0.0, 0.55, 5.0), mat_dark)
	_add_box(self, "DashBulk", Vector3(6.1, 0.9, 0.85), Vector3(0.0, -0.28, -1.36), mat_warm_dark)

	_add_box(self, "WindshieldGlass", Vector3(5.3, 1.35, 0.04), Vector3(0.0, 1.25, -1.86), mat_glass)
	_add_box(self, "WindshieldTopFrame", Vector3(5.8, 0.18, 0.18), Vector3(0.0, 2.05, -1.78), mat_dark)
	_add_box(self, "WindshieldBottomFrame", Vector3(5.8, 0.18, 0.18), Vector3(0.0, 0.48, -1.78), mat_dark)
	_add_box(self, "LeftAFrame", Vector3(0.18, 1.7, 0.18), Vector3(-2.95, 1.25, -1.78), mat_dark)
	_add_box(self, "RightAFrame", Vector3(0.18, 1.7, 0.18), Vector3(2.95, 1.25, -1.78), mat_dark)
	_add_box(self, "LeftSideWindow", Vector3(0.04, 1.0, 1.4), Vector3(-3.34, 1.15, 0.7), mat_glass)
	_add_box(self, "RightSideWindow", Vector3(0.04, 1.0, 1.4), Vector3(3.34, 1.15, 0.7), mat_glass)

	windshield_snow = _add_box(self, "WindshieldSnow", Vector3(5.15, 1.2, 0.035), Vector3(0.0, 1.25, -1.82), mat_snow)
	windshield_snow.visible = false

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
	_add_box(self, "Blanket", Vector3(1.4, 0.18, 1.0), Vector3(-2.1, -0.86, 3.6), mat_warm)
	_add_box(self, "OldPhoto", Vector3(0.55, 0.36, 0.04), Vector3(-1.95, 0.55, -0.76), mat_blue)
	_add_box(self, "TinCup", Vector3(0.28, 0.34, 0.28), Vector3(1.9, -0.64, -0.35), mat_metal)
	_add_box(self, "HangingCharm", Vector3(0.12, 0.26, 0.04), Vector3(0.45, 1.82, -1.62), mat_warm_emissive)

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
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = emission_energy
	return material
