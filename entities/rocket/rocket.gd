class_name Rocket
extends StaticBody2D

signal rocket_start

@export var spawn_opened = true
@export var spawn_with_lever := true
@export var spawn_with_particles := false

@onready var camera: GlobalCamera = get_tree().get_first_node_in_group("camera")
@onready var collision_door: CollisionShape2D = $CollisionDoor
@onready var door_sprite: Sprite2D = $Sprites/Door
@onready var crash_sprite: Sprite2D = $Sprites/Crash
@onready var lever: Lever = $Lever
@onready var particles: GPUParticles2D = $GPUParticles2D

func _ready() -> void:
	if not spawn_with_particles:
		particles.emitting = false
	if spawn_opened:
		open_door()
	else:
		close_door()
	if not spawn_with_lever:
		lever.visible = false
		lever.disabled

func start() -> void:
	close_door()
	lever.disabled = true
	rocket_start.emit()
	particles.emitting = true
	camera.translate_with_node(self, global_position)

func crash() -> void:
	particles.speed_scale = 1
	camera.start_shake(10)
	crash_sprite.visible = true
	var timer: SceneTreeTimer = get_tree().create_timer(1)
	await timer.timeout
	camera.stop_shake()
	open_door()

func open_door() -> void:
	collision_door.disabled = true
	door_sprite.visible = false

func close_door() -> void:
	collision_door.disabled = false
	door_sprite.visible = true

func _on_lever_toggled() -> void:
	start()
