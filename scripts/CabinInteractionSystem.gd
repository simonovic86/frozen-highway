class_name CabinInteractionSystem
extends RayCast3D

signal focus_text_changed(text)

var focus_probe_distance := 4.25
var current_text := ""

func _ready() -> void:
	enabled = true
	if not target_position.is_zero_approx():
		target_position = target_position.normalized() * focus_probe_distance

func _process(_delta: float) -> void:
	force_raycast_update()
	var text := ""
	var collider := get_collider()
	if collider != null and collider.has_method("get_interaction_text"):
		if _is_collider_in_reach(collider):
			text = collider.get_interaction_text()
		else:
			text = "Move closer"
	if text != current_text:
		current_text = text
		focus_text_changed.emit(current_text)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		force_raycast_update()
		var collider := get_collider()
		if collider != null and collider.has_method("interact") and _is_collider_in_reach(collider):
			collider.interact()

func _is_collider_in_reach(collider: Object) -> bool:
	if collider.has_method("is_interaction_point_in_range"):
		return collider.is_interaction_point_in_range(global_position, get_collision_point())
	return true
