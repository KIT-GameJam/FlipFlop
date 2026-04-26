extends StaticBody2D

signal rocket_start

@onready var collision_door: CollisionShape2D = $CollisionDoor
@onready var door: Sprite2D = $Door
@onready var camera_2d: Camera2D = $Camera2D

func _on_lever_toggled() -> void:
	collision_door.disabled = false
	door.visible = true
	rocket_start.emit()
	camera_2d.enabled = true
