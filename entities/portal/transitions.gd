@tool
class_name LevelTransition
extends Area2D

signal player_entered

enum Side { LEFT, RIGHT }

@export var level := AbstractLevel.Level.Start
@export var side := Side.RIGHT : set = _set_side
@export var height: int = 1 : set = _set_heigth
@export var spawn_black := false : set = _set_spawn_black

@onready var door_frame: Line2D = $Visual/DoorFrame
@onready var arrow_1: Polygon2D = $Visual/Arrow1
@onready var arrow_2: Polygon2D = $Visual/Arrow2
@onready var arrow_3: Polygon2D = $Visual/Arrow3
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@onready var visual: Node2D = $Visual

func _ready() -> void:
	_apply_spawn_black()
	_apply_side()
	_apply_height()

func _set_side(value: int) -> void:
	side = value
	if is_inside_tree():
		_apply_side()

func _set_spawn_black(value: bool) -> void:
	spawn_black = value
	if is_inside_tree():
		_apply_spawn_black()

func _set_heigth(value: int) -> void:
	height = value
	if is_inside_tree():
		_apply_height()

func _apply_height() -> void:
	if not is_inside_tree():
		return
	var cs := get_node_or_null("CollisionShape2D") as CollisionShape2D
	var df := get_node_or_null("Visual/DoorFrame") as Line2D
	if cs == null or df == null:
		return
	var shape := cs.shape as RectangleShape2D
	if shape != null:
		if not shape.resource_local_to_scene:
			shape = shape.duplicate() as RectangleShape2D
			shape.resource_local_to_scene = true
			cs.shape = shape
		shape.size.y = 40 * height
		cs.position.y = -20 * height
	df.points = PackedVector2Array([
		Vector2(20, -40 * height + 20),
		Vector2(20, 20),
	])

func _apply_spawn_black() -> void:
	if door_frame == null:
		return
	var color := Color.BLACK if spawn_black else Color.WHITE
	door_frame.self_modulate = color
	arrow_1.color = color
	arrow_2.color = color
	arrow_3.color = color

func _apply_side() -> void:
	if visual == null:
		return
	visual.scale.x = -1.0 if side == Side.LEFT else 1.0
	visual.position.x = -20.0 if side == Side.LEFT else 20.0

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_entered.emit()
		Global.game_manager.enter_transition(level, side)
