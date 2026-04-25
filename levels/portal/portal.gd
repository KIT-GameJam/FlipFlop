class_name Portal
extends Node2D

@export var level := AbstractLevel.Level.Level1;
@export_range(0, 10) var entrance := 0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		Global.game_manager.change_level(level, entrance)
