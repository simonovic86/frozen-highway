class_name CabinInteractionSystem
extends RayCast3D

signal focus_text_changed(text)

var focus_probe_distance := 4.25
var current_text := ""
var hold_collider: Object
var hold_elapsed := 0.0
var hold_duration := 0.0

func _ready() -> void:
	enabled = true
	if not target_position.is_zero_approx():
		target_position = target_position.normalized() * focus_probe_distance

func _process(delta: float) -> void:
	force_raycast_update()
	var collider := get_collider()
	var text := _get_focus_text(collider)

	if hold_collider != null:
		text = _update_hold(delta, collider)

	if text != current_text:
		current_text = text
		focus_text_changed.emit(current_text)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		force_raycast_update()
		var collider := get_collider()
		if collider != null and collider.has_method("interact") and _is_collider_in_reach(collider):
			var duration := _get_hold_duration(collider)
			if duration > 0.0:
				_start_hold(collider, duration)
			else:
				collider.interact()
	if event.is_action_released("interact"):
		_reset_hold()

func _get_focus_text(collider: Object) -> String:
	var text := ""
	if collider != null and collider.has_method("get_interaction_text"):
		if _is_collider_in_reach(collider):
			text = collider.get_interaction_text()
		else:
			text = "Move closer"
	return text

func _start_hold(collider: Object, duration: float) -> void:
	hold_collider = collider
	hold_elapsed = 0.0
	hold_duration = duration

func _update_hold(delta: float, current_collider: Object) -> String:
	if not Input.is_action_pressed("interact") or current_collider != hold_collider or not _is_collider_in_reach(current_collider):
		_reset_hold()
		return _get_focus_text(current_collider)

	hold_elapsed += delta
	var progress := clampf(hold_elapsed / hold_duration, 0.0, 1.0)
	var text := "Holding %d%%" % int(progress * 100.0)
	if hold_collider.has_method("get_hold_progress_text"):
		text = hold_collider.get_hold_progress_text(progress)

	if hold_elapsed >= hold_duration:
		var completed_collider := hold_collider
		_reset_hold()
		if completed_collider != null and completed_collider.has_method("interact"):
			completed_collider.interact()
		return _get_focus_text(current_collider)
	return text

func _reset_hold() -> void:
	hold_collider = null
	hold_elapsed = 0.0
	hold_duration = 0.0

func _get_hold_duration(collider: Object) -> float:
	if collider.has_method("get_hold_duration"):
		return collider.get_hold_duration()
	return 0.0

func _is_collider_in_reach(collider: Object) -> bool:
	if collider.has_method("is_interaction_point_in_range"):
		return collider.is_interaction_point_in_range(global_position, get_collision_point())
	return true
