class_name Portal
extends Node2D

signal player_entered

@export var active := true
@export var remove_player := false
@export var level := AbstractLevel.Level.Start;
@export_range(0, 10) var entrance := 0
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		player_entered.emit()
		if active:
			Global.game_manager.change_level(level, entrance)
		elif remove_player:
			body.queue_free()

func _ready() -> void:
	animation_player.play("spin")
