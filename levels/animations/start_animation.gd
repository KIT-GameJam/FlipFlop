extends AnimationPlayer

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var camera: GlobalCamera = get_tree().get_first_node_in_group("camera")
@onready var rocket: Rocket = $"../Rocket"

func _ready() -> void:
	camera.offset.y = -4100
	play("crash_rocket")

func _process(delta: float) -> void:
	player.global_position = rocket.global_position + Vector2(0, 160)

func _on_camera_follow_body_entered(body: Node2D) -> void:
	if body == player:
		camera.translate_with_node(rocket, Vector2(rocket.global_position.x, 430))

func _on_animation_finished(anim_name: StringName) -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	camera.stop_translations()
	rocket.crash()
