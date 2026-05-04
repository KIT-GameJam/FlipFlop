extends Node

#region Showing new Screens
signal game_pause
signal game_unpause
signal game_debug_show
signal game_debug_hide
signal input_type_changed(type: InputType)
#endregion

#region Game State Management
var _is_in_game: bool = false
var _is_paused: bool = false
var is_debug_label_visible: bool = false
var capture_mouse_ingame: bool = true
#endregion

enum InputType {KEYBOARD, JOYPAD}

var current_input_type: InputType = InputType.KEYBOARD

func _ready():
	set_process_mode(Node.PROCESS_MODE_ALWAYS)

func _input(event: InputEvent) -> void:
	_track_input_type(event)

	if event.is_action_pressed("pause"):
		if (_is_in_game and not _is_paused):
			game_pause.emit()
		elif (_is_in_game and _is_paused):
			game_unpause.emit()
	elif event.is_action_pressed("toggle_debug_label"):
		if is_debug_label_visible:
			game_debug_hide.emit()
		else:
			game_debug_show.emit()
	elif not _is_in_game: 
		pass

func _track_input_type(event: InputEvent) -> void:
	var new_type := current_input_type
	if event is InputEventKey or event is InputEventMouseButton:
		new_type = InputType.KEYBOARD
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		new_type = InputType.JOYPAD
	if new_type != current_input_type:
		current_input_type = new_type
		input_type_changed.emit(new_type)

func set_is_in_game(b: bool) -> void:
	_is_in_game = b
	_update_mouse_capture()

func _update_mouse_capture() -> void:
	if capture_mouse_ingame:
		if (not _is_in_game) || _is_paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func set_is_paused(b: bool) -> void:
	_is_paused = b
	_update_mouse_capture()
