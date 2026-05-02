class_name RadioSystem
extends Node

signal radio_state_changed(is_on)
signal message_changed(text)

var is_on := true
var override_timer := 0.0
var station_index := 0
var current_message := ""
var station_names := [
	"WEATHER",
	"COMPANY",
	"EMERGENCY"
]
var station_messages := [
	"...weather band... ice shear crossing Route 9. Keep speed steady.",
	"...company channel... morale is optional. Diesel is not.",
	"...emergency loop... black lights past kilometer nine. Do not stop."
]

func _ready() -> void:
	_set_message(station_messages[station_index])

func _process(delta: float) -> void:
	if not is_on:
		return

	if override_timer > 0.0:
		override_timer -= delta
		if override_timer <= 0.0:
			_set_message(station_messages[station_index])

func toggle_radio() -> void:
	tune_next_station()

func tune_next_station() -> void:
	station_index = (station_index + 1) % station_messages.size()
	is_on = true
	override_timer = 0.0
	radio_state_changed.emit(is_on)
	_set_message(station_messages[station_index])

func get_station_name() -> String:
	return station_names[station_index]

func broadcast_event_message(text: String, duration: float = 9.0) -> void:
	override_timer = duration
	if is_on:
		_set_message(text)

func _set_message(text: String) -> void:
	current_message = text
	message_changed.emit(current_message)
