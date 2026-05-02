class_name RoadGenerator
extends Node3D

var drive_speed := 20.0
var segment_length := 36.0
var segment_count := 8
var storm_intensity := 0.24
var rng := RandomNumberGenerator.new()

var segments: Array[Node3D] = []
var snowflakes: Array[MeshInstance3D] = []
var event_objects: Array[Node3D] = []
var distant_light_rigs: Array[Node3D] = []

var mat_road: StandardMaterial3D
var mat_snow: StandardMaterial3D
var mat_line: StandardMaterial3D
var mat_dark: StandardMaterial3D
var mat_light: StandardMaterial3D
var mat_distant_light: StandardMaterial3D
var snow_mesh: BoxMesh

func _ready() -> void:
	rng.randomize()
	_create_materials()
	_build_segments()
	_build_snow()
	_build_distant_moving_lights()

func _process(delta: float) -> void:
	_move_segments(delta)
	_move_snow(delta)
	_move_event_objects(delta)
	_move_distant_lights(delta)

func set_drive_speed(new_speed: float) -> void:
	drive_speed = new_speed

func set_storm_intensity(value: float) -> void:
	storm_intensity = clampf(value, 0.0, 1.0)

func spawn_headlights() -> void:
	var rig := Node3D.new()
	rig.name = "SuspiciousHeadlights"
	rig.position = Vector3(0.0, 0.0, -96.0)
	add_child(rig)

	for x in [-1.0, 1.0]:
		var bulb := MeshInstance3D.new()
		var mesh := SphereMesh.new()
		mesh.radius = 0.24
		mesh.height = 0.48
		bulb.mesh = mesh
		bulb.material_override = mat_light
		bulb.position = Vector3(x, 1.05, 0.0)
		rig.add_child(bulb)

		var light := OmniLight3D.new()
		light.light_color = Color(0.78, 0.95, 1.0)
		light.light_energy = 2.3
		light.omni_range = 12.0
		light.position = Vector3(x, 1.05, 0.0)
		rig.add_child(light)

	event_objects.append(rig)

func spawn_opening_distant_lights() -> void:
	var rig := Node3D.new()
	rig.name = "OpeningDistantLights"
	rig.position = Vector3(-0.6, 1.1, -128.0)
	rig.set_meta("drift", 0.08)
	rig.set_meta("phase", rng.randf_range(0.0, TAU))
	add_child(rig)
	distant_light_rigs.append(rig)

	for x in [-0.42, 0.42]:
		var bulb := MeshInstance3D.new()
		var mesh := SphereMesh.new()
		mesh.radius = 0.18
		mesh.height = 0.36
		bulb.mesh = mesh
		bulb.material_override = mat_light
		bulb.position = Vector3(x, 0.0, 0.0)
		rig.add_child(bulb)

		var lamp := OmniLight3D.new()
		lamp.light_color = Color(0.72, 0.9, 1.0)
		lamp.light_energy = 1.8
		lamp.omni_range = 16.0
		lamp.position = Vector3(x, 0.0, 0.0)
		rig.add_child(lamp)

func spawn_abandoned_vehicle() -> void:
	var wreck := Node3D.new()
	wreck.name = "AbandonedVehicle"
	wreck.position = Vector3(rng.randf_range(-2.7, 2.7), -0.52, -112.0)
	add_child(wreck)

	_add_box(wreck, "WreckBody", Vector3(2.2, 0.8, 3.6), Vector3.ZERO, mat_dark)
	_add_box(wreck, "SnowCap", Vector3(2.3, 0.16, 3.2), Vector3(0.0, 0.48, 0.0), mat_snow)
	_add_box(wreck, "ColdWindow", Vector3(1.2, 0.45, 0.08), Vector3(0.0, 0.15, -1.82), mat_light)
	event_objects.append(wreck)

func _create_materials() -> void:
	mat_road = _mat(Color(0.035, 0.04, 0.048), Color.BLACK, 0.0)
	mat_snow = _mat(Color(0.73, 0.82, 0.92), Color(0.08, 0.13, 0.18), 0.05)
	mat_line = _mat(Color(0.82, 0.88, 0.92), Color(0.18, 0.24, 0.28), 0.08)
	mat_dark = _mat(Color(0.035, 0.043, 0.052), Color.BLACK, 0.0)
	mat_light = _mat(Color(0.65, 0.9, 1.0), Color(0.45, 0.8, 1.0), 1.6)
	mat_distant_light = _mat(Color(1.0, 0.52, 0.24), Color(1.0, 0.32, 0.08), 2.1)

func _build_segments() -> void:
	for i in segment_count:
		var segment := Node3D.new()
		segment.name = "RoadSegment%02d" % i
		segment.position.z = -8.0 - float(i) * segment_length
		add_child(segment)
		segments.append(segment)
		_populate_segment(segment, i)

func _populate_segment(segment: Node3D, index: int) -> void:
	_add_box(segment, "Road", Vector3(7.2, 0.08, segment_length), Vector3(0.0, -0.74, 0.0), mat_road)
	_add_box(segment, "LeftSnowBank", Vector3(16.0, 0.12, segment_length), Vector3(-11.6, -0.78, 0.0), mat_snow)
	_add_box(segment, "RightSnowBank", Vector3(16.0, 0.12, segment_length), Vector3(11.6, -0.78, 0.0), mat_snow)

	for offset in [-9.0, 0.0, 9.0]:
		_add_box(segment, "LaneMark", Vector3(0.12, 0.03, 3.8), Vector3(0.0, -0.68, offset), mat_line)

	if index % 2 == 0:
		var side := -1.0 if index % 4 == 0 else 1.0
		_add_box(segment, "DistantSignPost", Vector3(0.12, 1.4, 0.12), Vector3(side * 5.6, 0.0, -8.0), mat_dark)
		_add_box(segment, "DistantSignFace", Vector3(1.2, 0.55, 0.08), Vector3(side * 5.6, 0.9, -8.0), mat_dark)
	if index % 3 == 1:
		var wreck_side := -1.0 if index % 2 == 1 else 1.0
		_build_roadside_vehicle_silhouette(segment, wreck_side, 4.0)

func _move_segments(delta: float) -> void:
	var movement := drive_speed * delta
	for segment in segments:
		segment.position.z += movement
		if segment.position.z > segment_length:
			segment.position.z -= segment_length * float(segment_count)

func _build_snow() -> void:
	snow_mesh = BoxMesh.new()
	snow_mesh.size = Vector3(0.035, 0.035, 0.035)
	for i in 240:
		var flake := MeshInstance3D.new()
		flake.name = "Snowflake%03d" % i
		flake.mesh = snow_mesh
		flake.material_override = mat_snow
		flake.position = _random_snow_position()
		add_child(flake)
		snowflakes.append(flake)

func _move_snow(delta: float) -> void:
	var wind := lerpf(0.4, 3.0, storm_intensity)
	var fall := lerpf(0.8, 2.6, storm_intensity)
	var forward := drive_speed * lerpf(0.65, 1.3, storm_intensity)
	for flake in snowflakes:
		flake.position.z += forward * delta
		flake.position.x += wind * delta
		flake.position.y -= fall * delta
		if flake.position.z > 8.0 or flake.position.y < -0.6 or absf(flake.position.x) > 18.0:
			flake.position = _random_snow_position()

func _build_roadside_vehicle_silhouette(parent: Node, side: float, z_offset: float) -> void:
	var wreck := Node3D.new()
	wreck.name = "RoadsideAbandonedVehicle"
	wreck.position = Vector3(side * 6.4, -0.54, z_offset)
	wreck.rotation_degrees.y = side * -7.0
	parent.add_child(wreck)

	_add_box(wreck, "LongDeadBody", Vector3(2.4, 0.62, 3.6), Vector3(0.0, 0.12, 0.0), mat_dark)
	_add_box(wreck, "CollapsedCab", Vector3(1.55, 0.72, 1.45), Vector3(0.2, 0.76, -0.62), mat_dark)
	_add_box(wreck, "SnowLoadedRoof", Vector3(1.7, 0.14, 1.55), Vector3(0.16, 1.18, -0.62), mat_snow)
	_add_box(wreck, "SnowPackedHood", Vector3(2.25, 0.12, 1.35), Vector3(0.0, 0.5, 1.0), mat_snow)
	_add_box(wreck, "ColdWindshield", Vector3(1.05, 0.34, 0.06), Vector3(0.2, 0.84, -1.38), mat_light)
	for x in [-0.92, 0.92]:
		_add_box(wreck, "BuriedWheel", Vector3(0.38, 0.38, 0.18), Vector3(x, -0.24, -1.05), mat_dark)
		_add_box(wreck, "BuriedWheel", Vector3(0.38, 0.38, 0.18), Vector3(x, -0.24, 1.05), mat_dark)
	_add_box(wreck, "LeaningMarker", Vector3(0.08, 1.1, 0.08), Vector3(side * -1.55, 0.3, 1.75), mat_dark)

func _build_distant_moving_lights() -> void:
	for i in 4:
		var rig := Node3D.new()
		rig.name = "DistantMovingLights%02d" % i
		rig.position = Vector3(
			(-1.0 if i % 2 == 0 else 1.0) * rng.randf_range(13.0, 22.0),
			rng.randf_range(0.6, 1.4),
			rng.randf_range(-132.0, -42.0)
		)
		rig.set_meta("drift", rng.randf_range(-0.65, 0.65))
		rig.set_meta("phase", rng.randf_range(0.0, TAU))
		add_child(rig)
		distant_light_rigs.append(rig)

		for x in [-0.28, 0.28]:
			var bulb := MeshInstance3D.new()
			var mesh := SphereMesh.new()
			mesh.radius = 0.13
			mesh.height = 0.26
			bulb.mesh = mesh
			bulb.material_override = mat_distant_light
			bulb.position = Vector3(x, 0.0, 0.0)
			rig.add_child(bulb)

		var glow := OmniLight3D.new()
		glow.name = "DistantGlow"
		glow.light_color = Color(1.0, 0.48, 0.22)
		glow.light_energy = 0.9
		glow.omni_range = 9.0
		rig.add_child(glow)

func _move_distant_lights(delta: float) -> void:
	for rig in distant_light_rigs:
		var phase := float(rig.get_meta("phase"))
		var drift := float(rig.get_meta("drift"))
		rig.position.z += (drive_speed * 0.24 + 2.8) * delta
		rig.position.x += drift * delta
		rig.position.y = 1.0 + sin(Time.get_ticks_msec() * 0.0017 + phase) * 0.18
		rig.scale = Vector3.ONE * (0.82 + sin(Time.get_ticks_msec() * 0.004 + phase) * 0.08)
		if rig.position.z > 16.0:
			rig.position.z = rng.randf_range(-150.0, -106.0)
			rig.position.x = signf(rig.position.x) * rng.randf_range(13.0, 24.0)
			rig.set_meta("drift", rng.randf_range(-0.65, 0.65))

func _move_event_objects(delta: float) -> void:
	var movement := drive_speed * delta
	for i in range(event_objects.size() - 1, -1, -1):
		var obj := event_objects[i]
		if obj == null:
			event_objects.remove_at(i)
			continue
		obj.position.z += movement
		if obj.name == "SuspiciousHeadlights":
			obj.scale = Vector3.ONE * (1.0 + sin(Time.get_ticks_msec() * 0.008) * 0.08)
		if obj.position.z > 14.0:
			obj.queue_free()
			event_objects.remove_at(i)

func _random_snow_position() -> Vector3:
	return Vector3(rng.randf_range(-15.0, 15.0), rng.randf_range(0.0, 7.5), rng.randf_range(-90.0, -4.0))

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

func _mat(color: Color, emission: Color, emission_energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = emission_energy
	return material
