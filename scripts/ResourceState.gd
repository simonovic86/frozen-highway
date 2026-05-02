class_name ResourceState
extends Node

signal changed(fuel, cabin_heat, engine_condition)
signal toggles_changed(heater_on, cabin_lights_on)

var fuel := 100.0
var cabin_heat := 60.0
var engine_condition := 96.0
var heater_on := false
var cabin_lights_on := true
var storm_intensity := 0.0

func update_drive(delta: float, speed: float) -> void:
	if fuel <= 0.0:
		changed.emit(fuel, cabin_heat, engine_condition)
		return

	var drain := 0.018 + speed * 0.0012
	if heater_on:
		drain += 0.006
	fuel = maxf(0.0, fuel - drain * delta)

	var outside_pressure := lerpf(42.0, 25.0, storm_intensity)
	var heat_target := 82.0 if heater_on else outside_pressure
	cabin_heat = move_toward(cabin_heat, heat_target, delta * (3.6 if heater_on else 1.7))

	var wear := (0.0018 + storm_intensity * 0.0025) * delta
	engine_condition = maxf(0.0, engine_condition - wear)

	changed.emit(fuel, cabin_heat, engine_condition)

func toggle_heater() -> void:
	set_heater_on(not heater_on)

func set_heater_on(enabled: bool) -> void:
	heater_on = enabled
	toggles_changed.emit(heater_on, cabin_lights_on)

func toggle_cabin_lights() -> void:
	set_cabin_lights_on(not cabin_lights_on)

func set_cabin_lights_on(enabled: bool) -> void:
	cabin_lights_on = enabled
	toggles_changed.emit(heater_on, cabin_lights_on)

func set_storm_intensity(value: float) -> void:
	storm_intensity = clampf(value, 0.0, 1.0)
