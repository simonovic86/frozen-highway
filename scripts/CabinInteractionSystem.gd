class_name CabinInteractionSystem
extends RayCast3D

signal focus_text_changed(text)

var current_text := ""

func _ready() -> void:
	enabled = true

func _process(_delta: float) -> void:
	force_raycast_update()
	var text := ""
	var collider := get_collider()
	if collider != null and collider.has_method("get_interaction_text"):
		text = collider.get_interaction_text()
	if text != current_text:
		current_text = text
		focus_text_changed.emit(current_text)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		force_raycast_update()
		var collider := get_collider()
		if collider != null and collider.has_method("interact"):
			collider.interact()
