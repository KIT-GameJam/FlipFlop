extends StaticBody2D

signal rocket_start

@onready var camera: GlobalCamera = get_tree().get_first_node_in_group("camera")
@onready var collision_door: CollisionShape2D = $CollisionDoor
@onready var door: Sprite2D = $Door
@onready var lever: Lever = $Lever

func _on_lever_toggled() -> void:
	collision_door.disabled = false
	lever.disabled = true
	door.visible = true
	rocket_start.emit()
	camera.translate_with_node(self)
