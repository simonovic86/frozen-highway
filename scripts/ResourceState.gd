class_name ResourceState
extends Node

signal changed(fuel, cabin_heat, engine_condition)
signal toggles_changed(heater_on, cabin_lights_on)

const HEATER_OFF := 0
const HEATER_LOW := 1
const HEATER_HIGH := 2
const LOW_FUEL_THRESHOLD := 20.0
const HIGH_SPEED_STRESS_THRESHOLD := 25.0
const SAFE_ENGINE_SPEED := 18.0

var fuel := 100.0
var cabin_heat := 60.0
var engine_condition := 96.0
var heater_level := HEATER_OFF
var heater_on := false
var cabin_lights_on := true
var storm_intensity := 0.0
var high_speed_stress := 0.0

func update_drive(delta: float, speed: float) -> void:
	if fuel <= 0.0:
		changed.emit(fuel, cabin_heat, engine_condition)
		return

	var drain := 0.026 + speed * 0.0016
	if heater_level == HEATER_LOW:
		drain += 0.003
	elif heater_level == HEATER_HIGH:
		drain += 0.008
	fuel = maxf(0.0, fuel - drain * delta)

	var outside_pressure := lerpf(42.0, 25.0, storm_intensity)
	var heat_target := outside_pressure
	var heat_rate := 1.7
	if heater_level == HEATER_LOW:
		heat_target = 70.0
		heat_rate = 2.5
	elif heater_level == HEATER_HIGH:
		heat_target = 86.0
		heat_rate = 4.2
	cabin_heat = move_toward(cabin_heat, heat_target, delta * heat_rate)

	var speed_pressure := clampf((speed - HIGH_SPEED_STRESS_THRESHOLD) / 7.0, 0.0, 1.0)
	var stress_rate := 0.12 if speed_pressure > high_speed_stress else 0.26
	high_speed_stress = move_toward(high_speed_stress, speed_pressure, delta * stress_rate)

	var wear := (0.0018 + storm_intensity * 0.0025 + high_speed_stress * speed_pressure * 0.32) * delta
	var recovery := 0.0
	if speed < SAFE_ENGINE_SPEED and fuel > 0.0:
		var recovery_pressure := clampf((SAFE_ENGINE_SPEED - speed) / (SAFE_ENGINE_SPEED - 8.0), 0.0, 1.0)
		recovery = (0.08 + recovery_pressure * 0.16) * delta
	engine_condition = clampf(engine_condition - wear + recovery, 0.0, 100.0)

	changed.emit(fuel, cabin_heat, engine_condition)

func toggle_heater() -> void:
	cycle_heater_level()

func set_heater_on(enabled: bool) -> void:
	set_heater_level(HEATER_LOW if enabled else HEATER_OFF)

func cycle_heater_level() -> void:
	set_heater_level((heater_level + 1) % 3)

func set_heater_level(level: int) -> void:
	heater_level = clampi(level, HEATER_OFF, HEATER_HIGH)
	heater_on = heater_level > HEATER_OFF
	toggles_changed.emit(heater_on, cabin_lights_on)

func toggle_cabin_lights() -> void:
	set_cabin_lights_on(not cabin_lights_on)

func set_cabin_lights_on(enabled: bool) -> void:
	cabin_lights_on = enabled
	toggles_changed.emit(heater_on, cabin_lights_on)

func set_storm_intensity(value: float) -> void:
	storm_intensity = clampf(value, 0.0, 1.0)
