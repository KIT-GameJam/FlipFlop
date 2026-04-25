class_name Player
extends CharacterBody2D

@onready var hit_box: CollisionShape2D = $HitBox/CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var flipped: bool = false
@onready var in_flipping_animation: bool = false

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -300.0
const COYOTE_TIME: float = 0.1

var coyote_timer: float = 0.0

func _ready():
	sprite.modulate = Color.BLACK

func flip() -> void:
	_perform_flip(not flipped)

func is_on_ground() -> bool:
	return (is_on_ceiling() if flipped else is_on_floor())

func _perform_flip(to_flipped: bool) -> void:
	var target_collision_position := Vector2(0, 35 if to_flipped else -35)
	var mask_to_enable := 2 if to_flipped else 3
	var mask_to_disable := 3 if to_flipped else 2

	set_collision_mask_value(mask_to_enable, true)
	set_collision_mask_value(mask_to_disable, false)

	if not _can_flip_to(target_collision_position):
		set_collision_mask_value(mask_to_disable, true)
		set_collision_mask_value(mask_to_enable, false)
		_fail_flip()
		return

	collision_shape.position = target_collision_position
	animation_player.play("flip_down" if to_flipped else "flip_up")
	in_flipping_animation = true
	flipped = to_flipped

func _can_flip_to(target_collision_position: Vector2) -> bool:
	var original_collision_position := collision_shape.position
	collision_shape.position = target_collision_position
	var is_blocked := test_move(global_transform, Vector2(0, _get_flipped_integer() * -1), null, 2, true)
	collision_shape.position = original_collision_position
	return not is_blocked

func _fail_flip():
	animation_player.play("flipflop_up" if flipped else "flipflop_down")
	in_flipping_animation = true

func _get_flipped_integer() -> int:
	return 1 if flipped else -1

func _physics_process(delta: float) -> void:
	var on_ground: bool = is_on_ground()

	if on_ground:
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta

	if Input.is_action_just_pressed("flip") and coyote_timer > 0:
		flip()
		coyote_timer = 0

	if not in_flipping_animation:
		# Add the gravity.
		if not on_ground and not in_flipping_animation:
			velocity += get_gravity() * delta * (-1 if flipped else 1)

		if Input.is_action_just_pressed("jump") and coyote_timer > 0:
			velocity.y = JUMP_VELOCITY * (-1 if flipped else 1)
			coyote_timer = 0

		var direction := Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = direction * SPEED
			if direction < 0:
				sprite.scale.x = -1
			elif direction > 0:
				sprite.scale.x = 1
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.x = 0

	move_and_slide()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	in_flipping_animation = false


func _on_kill_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		print("kill")
