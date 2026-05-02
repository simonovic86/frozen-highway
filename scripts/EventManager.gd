class_name EventManager
extends Node

signal event_started(kind)

var radio_system: Node
var resource_state: Node
var road_generator: Node
var cabin: Node

var event_timer := 7.0
var storm_timer := 0.0
var event_order := ["radio_distress", "snowstorm", "headlights", "abandoned_vehicle"]
var event_index := 0

func setup(new_resource_state: Node, new_radio_system: Node, new_road_generator: Node, new_cabin: Node) -> void:
	resource_state = new_resource_state
	radio_system = new_radio_system
	road_generator = new_road_generator
	cabin = new_cabin

func _process(delta: float) -> void:
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
