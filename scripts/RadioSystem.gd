class_name RadioSystem
extends Node

signal radio_state_changed(is_on)
signal message_changed(text)

var is_on := true
var message_timer := 3.0
var override_timer := 0.0
var message_index := 0
var current_message := ""
var static_messages := [
	"...static... route marker lost in whiteout...",
	"...heater line holding... keep moving...",
	"...black lights past kilometer nine... do not stop...",
	"...northbound lane closed by ice wrecks..."
]

func _ready() -> void:
	_set_message(static_messages[0])

func _process(delta: float) -> void:
	if not is_on:
		return

	if override_timer > 0.0:
		override_timer -= delta
		return

	message_timer -= delta
	if message_timer <= 0.0:
		message_index = (message_index + 1) % static_messages.size()
		_set_message(static_messages[message_index])
		message_timer = 12.0

func toggle_radio() -> void:
	is_on = not is_on
	radio_state_changed.emit(is_on)
	if is_on:
		_set_message(static_messages[message_index])
	else:
		_set_message("")

func broadcast_event_message(text: String, duration: float = 9.0) -> void:
	override_timer = duration
	if is_on:
		_set_message(text)

func _set_message(text: String) -> void:
	current_message = text
	message_changed.emit(current_message)
