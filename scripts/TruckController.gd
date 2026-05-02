class_name TruckController
extends Node

signal speed_changed(speed)

var resource_state: Node
var speed := 20.0
var target_speed := 20.0
var min_speed := 8.0
var max_speed := 32.0

func _process(delta: float) -> void:
	if Input.is_action_pressed("throttle_up"):
		target_speed = minf(max_speed, target_speed + 12.0 * delta)
	if Input.is_action_pressed("throttle_down"):
		target_speed = maxf(min_speed, target_speed - 12.0 * delta)
	if resource_state != null and resource_state.fuel <= 0.0:
		target_speed = 0.0

	speed = lerpf(speed, target_speed, 1.0 - exp(-3.5 * delta))
	if resource_state != null:
		resource_state.update_drive(delta, speed)
	speed_changed.emit(speed)
