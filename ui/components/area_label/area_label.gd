@tool
extends Area2D

@export_multiline() var text: String = "" : set = _set_text
@export var font_size: int = 48 : set = _set_font_size
@export var black_color: bool = true : set = _set_black_color
@export var spawn_visible: bool = false

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	_apply_all()
	if Engine.is_editor_hint():
		return
	InputManager.input_type_changed.connect(_on_input_type_changed)
	if spawn_visible:
		label.modulate = Color.WHITE
	else:
		label.modulate = Color.TRANSPARENT

func _on_input_type_changed(_type: InputManager.InputType) -> void:
	_apply_all()

func _apply_all() -> void:
	if not is_node_ready():
		return
	label.text = _resolve_bindings(text)
	label.label_settings = label.label_settings.duplicate()
	label.label_settings.font_size = font_size
	label.label_settings.font_color = Color.BLACK if black_color else Color.WHITE

func _resolve_bindings(raw: String) -> String:
	var regex := RegEx.new()
	regex.compile("\\{([a-zA-Z0-9_]+)\\}")
	var result := raw
	for m in regex.search_all(raw):
		var action := m.get_string(1)
		result = result.replace(m.get_string(0), _action_label(action))
	return result

func _action_label(action: StringName) -> String:
	if not InputMap.has_action(action):
		return "?"
	var prefer_joypad := not Engine.is_editor_hint() \
		and InputManager.current_input_type == InputManager.InputType.JOYPAD
	var events := InputMap.action_get_events(action)
	if prefer_joypad:
		for event in events:
			if event is InputEventJoypadButton:
				return _joypad_button_name(event.button_index)
			if event is InputEventJoypadMotion:
				return "Axis %d" % event.axis
	for event in events:
		if event is InputEventKey:
			var key: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
			return OS.get_keycode_string(key)
		if event is InputEventMouseButton:
			return "Mouse %d" % event.button_index
	for event in events:
		if event is InputEventJoypadButton:
			return _joypad_button_name(event.button_index)
		if event is InputEventJoypadMotion:
			return "Axis %d" % event.axis
	return "?"

func _joypad_button_name(idx: int) -> String:
	match idx:
		JOY_BUTTON_A: return "A"
		JOY_BUTTON_B: return "B"
		JOY_BUTTON_X: return "X"
		JOY_BUTTON_Y: return "Y"
		JOY_BUTTON_BACK: return "Back"
		JOY_BUTTON_START: return "Start"
		JOY_BUTTON_LEFT_SHOULDER: return "LB"
		JOY_BUTTON_RIGHT_SHOULDER: return "RB"
		JOY_BUTTON_LEFT_STICK: return "LS"
		JOY_BUTTON_RIGHT_STICK: return "RS"
		JOY_BUTTON_DPAD_UP: return "D-Up"
		JOY_BUTTON_DPAD_DOWN: return "D-Down"
		JOY_BUTTON_DPAD_LEFT: return "D-Left"
		JOY_BUTTON_DPAD_RIGHT: return "D-Right"
		_: return "Button %d" % idx

func _set_text(value: String) -> void:
	text = value
	_apply_all()

func _set_font_size(value: int) -> void:
	font_size = value
	_apply_all()

func _set_black_color(value: bool) -> void:
	black_color = value
	_apply_all()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		animation_player.play("fade_in")

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		animation_player.play("fade_out")
