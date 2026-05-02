class_name CabinInteractable
extends StaticBody3D

signal interacted(action_id)

var action_id := ""
var display_name := ""

func setup(new_action_id: String, new_display_name: String) -> void:
	action_id = new_action_id
	display_name = new_display_name

func get_interaction_text() -> String:
	return "E - " + display_name

func interact() -> void:
	interacted.emit(action_id)
