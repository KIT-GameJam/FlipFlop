extends Control

@onready var controls_text: Label = $ControlsTitle2

func _ready():
	$Continue.grab_focus()

func set_text(text: String) -> void:
	controls_text.text = text

func _on_continue_pressed() -> void:
	queue_free()
