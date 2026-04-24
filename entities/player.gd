class_name Player
extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var flipped: bool = false
@onready var in_flipping_animation = false

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -400.0

func _ready():
	sprite.modulate = Color.BLACK

func flip() -> void:
	if flipped:
		_flip_up()
	else: 
		_flip_down()

func is_on_ground() -> bool:
	return (is_on_ceiling() if flipped else is_on_floor())

func _flip_up() -> void:
	var target_collision_position := Vector2(0, -35)
	set_collision_mask_value(3, true)
	set_collision_mask_value(2, false)
	if not _can_flip_to(target_collision_position):
		set_collision_mask_value(2, true)
		set_collision_mask_value(3, false)
		_fail_flip()
		return
	collision_shape.position = target_collision_position
	animation_player.play("flip_up")
	in_flipping_animation = true
	flipped = false

func _flip_down() -> void:
	var target_collision_position := Vector2(0, 35)
	set_collision_mask_value(2, true)
	set_collision_mask_value(3, false)
	if not _can_flip_to(target_collision_position):
		set_collision_mask_value(3, true)
		set_collision_mask_value(2, false)
		_fail_flip()
		return
	collision_shape.position = target_collision_position
	animation_player.play("flip_down")
	in_flipping_animation = true
	flipped = true

func _can_flip_to(target_collision_position: Vector2) -> bool:
	var original_collision_position := collision_shape.position
	collision_shape.position = target_collision_position
	var is_blocked := test_move(global_transform, Vector2(0, _get_flipped_integer() * -1), null, 2, true)
	collision_shape.position = original_collision_position
	return not is_blocked

func _fail_flip():
	if flipped:
		animation_player.play("flipflop_up")
	else:
		animation_player.play("flipflop_down")

func _get_flipped_integer() -> int:
	return 1 if flipped else -1

func _physics_process(delta: float) -> void:
	var on_ground: bool = is_on_ground()
	# Add the gravity.
	if not on_ground:
		velocity += get_gravity() * delta * (-1 if flipped else 1)
	
	if Input.is_action_just_pressed("jump") and on_ground:
		velocity.y = JUMP_VELOCITY * (-1 if flipped else 1)
	elif Input.is_action_just_pressed("flip") and on_ground:
		flip()
	
	if not in_flipping_animation:
		var direction := Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.x = 0
	
	move_and_slide()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	in_flipping_animation = false
