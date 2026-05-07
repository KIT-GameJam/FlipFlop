class_name LevelTransition
extends Area2D

signal player_entered

enum Side { LEFT, RIGHT }

@export var level := AbstractLevel.Level.Start
@export var side := Side.RIGHT : set = _set_side

@onready var visual: Node2D = $Visual

func _ready() -> void:
	_apply_side()

func _set_side(value: int) -> void:
	side = value
	if is_inside_tree():
		_apply_side()

func _apply_side() -> void:
	if visual == null:
		return
	visual.scale.x = -1.0 if side == Side.LEFT else 1.0
	visual.position.x = -20.0 if side == Side.LEFT else 20.0

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_entered.emit()
		Global.game_manager.enter_transition(level, side)
