extends Node2D

signal player_entered

@export var level := AbstractLevel.Level.Start;
@export_range(0, 10) var entrance := 0

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_entered.emit()
		Global.game_manager.change_level(level, entrance)
