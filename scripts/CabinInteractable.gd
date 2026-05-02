class_name CabinInteractable
extends StaticBody3D

signal interacted(action_id)

var action_id := ""
var display_name := ""
var max_interaction_distance := 3.0
var hold_duration := 0.0

func setup(new_action_id: String, new_display_name: String, new_max_interaction_distance: float = 3.0, new_hold_duration: float = 0.0) -> void:
	action_id = new_action_id
	display_name = new_display_name
	max_interaction_distance = new_max_interaction_distance
	hold_duration = new_hold_duration

func get_interaction_text() -> String:
	if hold_duration > 0.0:
		return "Hold E - " + display_name
	return "E - " + display_name

func get_hold_progress_text(progress: float) -> String:
	return "Holding " + display_name + " %d%%" % int(progress * 100.0)

func get_hold_duration() -> float:
	return hold_duration

func is_interaction_point_in_range(origin: Vector3, interaction_point: Vector3) -> bool:
	return origin.distance_to(interaction_point) <= max_interaction_distance

func interact() -> void:
	interacted.emit(action_id)
