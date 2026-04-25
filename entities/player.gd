class_name Player
extends CharacterBody2D

@onready var hit_box_vertical: CollisionShape2D = $HitBoxVertical/CollisionShape2D
@onready var hit_box_horizontal: CollisionShape2D = $HitBoxHorizontal/CollisionShape2D
@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var walking_player: AudioStreamPlayer2D = $WalkingPlayer

@onready var flipped: bool = false
@onready var in_flipping_animation: bool = false
var last_direction: float = 0
const SPEED: float = 300.0
const JUMP_VELOCITY: float = -300.0
const COYOTE_TIME: float = 0.1

const LAYER_LIGHT := 2
const LAYER_DARK := 3

var coyote_timer: float = 0.0

func _ready():
	sprite.modulate = Color.BLACK

func flip() -> void:
	_perform_flip(not flipped)

func is_on_ground() -> bool:
	return (is_on_ceiling() if flipped else is_on_floor())

func set_flipped(to_flipped: bool) -> void:
	if to_flipped != flipped:
		set_collision_mask_value(LAYER_LIGHT, not get_collision_mask_value(LAYER_LIGHT))
		set_collision_mask_value(LAYER_DARK, not get_collision_mask_value(LAYER_DARK))
		collision_shape.position.y *= -1
		hit_box_vertical.position.y *= -1
		hit_box_horizontal.position.y *= -1
		sprite.position.y *= -1
		sprite.scale.y *= -1
		sprite.modulate = sprite.modulate.inverted()
		flipped = to_flipped

func _perform_flip(to_flipped: bool) -> void:
	var target_collision_position := Vector2(0, 35 if to_flipped else -35)
	var mask_to_enable := LAYER_LIGHT if to_flipped else LAYER_DARK
	var mask_to_disable := LAYER_DARK if to_flipped else LAYER_LIGHT

	set_collision_mask_value(mask_to_enable, true)
	set_collision_mask_value(mask_to_disable, false)

	var correction_offset: Variant = _get_flip_correction(target_collision_position)
	if correction_offset == null:
		set_collision_mask_value(mask_to_disable, true)
		set_collision_mask_value(mask_to_enable, false)
		_fail_flip()
		return

	global_position.x += correction_offset.x
	collision_shape.position = target_collision_position
	hit_box_vertical.position = target_collision_position
	hit_box_horizontal.position = target_collision_position
	animation_player.play(&"flip_down" if to_flipped else &"flip_up")
	in_flipping_animation = true
	flipped = to_flipped

func _get_flip_correction(target_collision_position: Vector2) -> Variant:
	var original_collision_position := collision_shape.position
	collision_shape.position = target_collision_position

	# Try direct flip first
	if not test_move(global_transform, Vector2(0, _get_flipped_integer() * -1), null, 2, true):
		collision_shape.position = original_collision_position
		return Vector2.ZERO

	# Try horizontal corrections
	var max_correction := 15.0
	var steps := 15
	for i in range(1, steps + 1):
		for direction in [-1, 1]:
			var offset_val: float = direction * (max_correction * i / steps)
			var test_transform := global_transform
			test_transform.origin.x += offset_val
			if not test_move(test_transform, Vector2(0, _get_flipped_integer() * -1), null, 2, true):
				collision_shape.position = original_collision_position
				return Vector2(offset_val, 0)

	collision_shape.position = original_collision_position
	return null

func _can_flip_to(target_collision_position: Vector2) -> bool:
	return _get_flip_correction(target_collision_position) != null

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
		elif Input.is_action_just_pressed("reset"):
			Global.game_manager.respawn()

		var direction := Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = direction * SPEED
			_update_walking_animation(direction)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			_stop_walking()

		last_direction = direction
	else:
		velocity.x = 0

	move_and_slide()

func _update_walking_animation(direction: float) -> void:
	if direction > 0:
		_walk_right()
	else:
		_walk_left()
	if sprite.animation != "walking":
		sprite.play("walking")

func _stop_walking() -> void:
	if sprite.animation != "idle":
		sprite.play("idle")

func _walk_left() -> void:
	sprite.scale.x = -1

func _walk_right() -> void:
	sprite.scale.x = 1

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	in_flipping_animation = false


func _on_kill_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		Global.game_manager.respawn()
