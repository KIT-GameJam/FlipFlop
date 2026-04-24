class_name Portal
extends Node2D


@export var level := AbstractLevel.Level.Level1;
@export var entrance = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_class("Player"):
		Global.game_manager.change_scene(level, entrance)
