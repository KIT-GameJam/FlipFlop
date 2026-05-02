extends Area2D

@export var text: String = ""
@export var font_size: int = 48
@export var black_color: bool = true
@export var spawn_visible: bool = false

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	label.text = text
	label.label_settings.font_size = font_size
	if not black_color:
		label.label_settings.font_color = Color.WHITE
	if spawn_visible:
		label.modulate = Color.WHITE
	else:
		label.modulate = Color.TRANSPARENT

func _on_body_entered(body: Node2D) -> void:
	if body == Player:
		animation_player.play("fade_in")

func _on_body_exited(body: Node2D) -> void:
	if body == Player:
		animation_player.play("fade_out")
