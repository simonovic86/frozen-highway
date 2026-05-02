class_name EventManager
extends Node

signal event_started(kind)

var radio_system: Node
var resource_state: Node
var road_generator: Node
var cabin: Node

var opening_elapsed := 0.0
var opening_radio_sent := false
var opening_lights_sent := false
var opening_flicker_sent := false
var event_timer := 34.0
var storm_timer := 0.0
var event_order := ["radio_distress", "snowstorm", "headlights", "abandoned_vehicle"]
var event_index := 0

func setup(new_resource_state: Node, new_radio_system: Node, new_road_generator: Node, new_cabin: Node) -> void:
	resource_state = new_resource_state
	radio_system = new_radio_system
	road_generator = new_road_generator
	cabin = new_cabin

func _process(delta: float) -> void:
	_update_opening_sequence(delta)

	if storm_timer > 0.0:
		storm_timer -= delta
		if storm_timer <= 0.0:
			if resource_state != null:
				resource_state.set_storm_intensity(0.0)
			if road_generator != null:
				road_generator.set_storm_intensity(0.0)
			if cabin != null and cabin.has_method("set_windshield_snow"):
				cabin.set_windshield_snow(false)

	event_timer -= delta
	if event_timer <= 0.0:
		_trigger_next_event()
		event_timer = 17.0

func _update_opening_sequence(delta: float) -> void:
	opening_elapsed += delta

	if not opening_radio_sent and opening_elapsed >= 10.0:
		opening_radio_sent = true
		event_started.emit("opening_radio_crackle")
		if radio_system != null:
			radio_system.broadcast_event_message("KRRRCH...\n...Route 9 cabin, keep warm.\nThey count lights before they count bodies.", 12.0)

	if not opening_lights_sent and opening_elapsed >= 14.5:
		opening_lights_sent = true
		event_started.emit("opening_distant_lights")
		if road_generator != null and road_generator.has_method("spawn_opening_distant_lights"):
			road_generator.spawn_opening_distant_lights()

	if not opening_flicker_sent and opening_elapsed >= 17.0:
		opening_flicker_sent = true
		event_started.emit("opening_light_flicker")
		if cabin != null and cabin.has_method("force_light_flicker"):
			cabin.force_light_flicker(0.42)

func _trigger_next_event() -> void:
	var kind: String = event_order[event_index]
	event_index = (event_index + 1) % event_order.size()
	event_started.emit(kind)

	match kind:
		"radio_distress":
			if radio_system != null:
				radio_system.broadcast_event_message("...anyone on Route 9... do not stop near the black lights. company will bill your next of kin...", 12.0)
		"snowstorm":
			storm_timer = 14.0
			if resource_state != null:
				resource_state.set_storm_intensity(1.0)
			if road_generator != null:
				road_generator.set_storm_intensity(1.0)
			if cabin != null and cabin.has_method("set_windshield_snow"):
				cabin.set_windshield_snow(true)
			if radio_system != null:
				radio_system.broadcast_event_message("...white wall moving across the road... keep the heater alive...", 10.0)
		"headlights":
			if road_generator != null:
				road_generator.spawn_headlights()
			if radio_system != null:
				radio_system.broadcast_event_message("...two lights behind you. no engine signature. do not answer...", 10.0)
		"abandoned_vehicle":
			if road_generator != null:
				road_generator.spawn_abandoned_vehicle()
			if radio_system != null:
				radio_system.broadcast_event_message("...wreck in the lane ahead. ease past it. no stopping. survivors get colder after paperwork...", 9.0)
