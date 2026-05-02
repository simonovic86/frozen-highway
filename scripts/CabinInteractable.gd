class_name CabinInteractable
extends StaticBody3D

signal interacted(action_id)

var action_id := ""
var display_name := ""
var max_interaction_distance := 3.0

func setup(new_action_id: String, new_display_name: String, new_max_interaction_distance: float = 3.0) -> void:
	action_id = new_action_id
	display_name = new_display_name
	max_interaction_distance = new_max_interaction_distance

func get_interaction_text() -> String:
	return "E - " + display_name

func is_interaction_point_in_range(origin: Vector3, interaction_point: Vector3) -> bool:
	return origin.distance_to(interaction_point) <= max_interaction_distance

func interact() -> void:
	interacted.emit(action_id)
