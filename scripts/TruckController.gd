class_name TruckController
extends Node

signal speed_changed(speed)

var resource_state: Node
var speed := 20.0
var target_speed := 20.0
var min_speed := 8.0
var max_speed := 32.0

func _process(delta: float) -> void:
	var engine_struggle := 0.0
	var effective_max_speed := max_speed
	if resource_state != null:
		engine_struggle = clampf((35.0 - resource_state.engine_condition) / 35.0, 0.0, 1.0)
		effective_max_speed = lerpf(max_speed, 22.0, engine_struggle)

	var cabin_movement_mode := Input.is_action_pressed("cabin_move_modifier")
	if not cabin_movement_mode and Input.is_action_pressed("throttle_up"):
		var acceleration := lerpf(12.0, 6.0, engine_struggle)
		target_speed = minf(effective_max_speed, target_speed + acceleration * delta)
	if not cabin_movement_mode and Input.is_action_pressed("throttle_down"):
		target_speed = maxf(min_speed, target_speed - 12.0 * delta)
	if target_speed > effective_max_speed:
		target_speed = lerpf(target_speed, effective_max_speed, 1.0 - exp(-1.4 * delta))
	if resource_state != null and resource_state.fuel <= 0.0:
		target_speed = 0.0

	speed = lerpf(speed, target_speed, 1.0 - exp(-3.5 * delta))
	if resource_state != null:
		resource_state.update_drive(delta, speed)
	speed_changed.emit(speed)
