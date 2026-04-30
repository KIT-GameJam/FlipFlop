class_name Player
extends CharacterBody2D

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -300.0
const COYOTE_TIME: float = 0.1
const LAYER_LIGHT := 2
const LAYER_DARK := 3

const SFX := {
	"walking": preload("res://assets/sfx/walking.mp3"),
	"jumping": preload("res://assets/sfx/jumping.mp3"),
	"landing": preload("res://assets/sfx/landing.mp3"),
	"flip": preload("res://assets/sfx/flip.mp3"),
}

@onready var hit_box_vertical: CollisionShape2D = $HitBoxVertical/CollisionShape2D
@onready var hit_box_horizontal: CollisionShape2D = $HitBoxHorizontal/CollisionShape2D
@onready var lever_area: CollisionShape2D = $LeverArea/CollisionShape2D
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var player_sfx_player: AudioStreamPlayer2D = $PlayerSfxPlayer

@onready var flipped: bool = false
@onready var in_flipping_animation: bool = false

var last_direction: float = 0.0
var coyote_timer: float = 0.0

var close_levers: Array[Lever] = []

func _ready():
	sprite.modulate = Color.BLACK

func flip() -> void:
	_perform_flip(not flipped)

func is_on_ground() -> bool:
	return (is_on_ceiling() if flipped else is_on_floor())

func set_flipped(to_flipped: bool) -> void:
	if in_flipping_animation:
		animation_player.stop()
		in_flipping_animation = false
	var s := 1.0 if to_flipped else -1.0
	set_collision_mask_value(LAYER_LIGHT, to_flipped)
	set_collision_mask_value(LAYER_DARK, not to_flipped)
	collision_shape.position.y = s * absf(collision_shape.position.y)
	hit_box_vertical.position.y = s * absf(hit_box_vertical.position.y)
	hit_box_horizontal.position.y = s * absf(hit_box_horizontal.position.y)
	lever_area.position.y = s * absf(lever_area.position.y)
	sprite.position.y = s * absf(sprite.position.y)
	sprite.scale.y = -s
	sprite.modulate = Color.WHITE if to_flipped else Color.BLACK
	flipped = to_flipped

func _perform_flip(to_flipped: bool) -> void:
	var target_collision_position := Vector2(0, 35 if to_flipped else -35)
	var mask_to_enable := LAYER_LIGHT if to_flipped else LAYER_DARK
	var mask_to_disable := LAYER_DARK if to_flipped else LAYER_LIGHT

	set_collision_mask_value(mask_to_enable, true)
	set_collision_mask_value(mask_to_disable, false)

	if not _can_flip_to(target_collision_position):
		set_collision_mask_value(mask_to_disable, true)
		set_collision_mask_value(mask_to_enable, false)
		_fail_flip()
		return

	collision_shape.position = target_collision_position
	hit_box_vertical.position = target_collision_position
	hit_box_horizontal.position = target_collision_position
	lever_area.position = target_collision_position
	animation_player.play(&"flip_down" if to_flipped else &"flip_up")
	player_sfx_player.play_sfx(SFX.flip)
	in_flipping_animation = true
	flipped = to_flipped

func _can_flip_to(target_collision_position: Vector2) -> Variant:
	var original_collision_position := collision_shape.position
	collision_shape.position = target_collision_position
	collision_shape.shape.size.x -= 10
	var is_blocked := test_move(global_transform, Vector2(0, _get_flipped_integer() * -1), null, 2, true)
	collision_shape.position = original_collision_position
	collision_shape.shape.size.x += 10
	return not is_blocked

func _fail_flip():
	animation_player.play(&"flipflop_up" if flipped else &"flipflop_down")
	in_flipping_animation = true

func _get_flipped_integer() -> int:
	return 1 if flipped else -1

func _physics_process(delta: float) -> void:
	if not in_flipping_animation:
		_apply_gravity(delta)
		_handle_input()
		_handle_movement()
	else:
		velocity.x = 0

	var was_grounded := is_on_ground()
	move_and_slide()

	if is_on_ground():
		coyote_timer = COYOTE_TIME
		if not was_grounded:
			_on_landed()
	else:
		coyote_timer -= delta

	_update_animations()

func _apply_gravity(delta: float) -> void:
	if not is_on_ground():
		velocity += get_gravity() * delta * (-1 if flipped else 1)

func _handle_input() -> void:
	if Input.is_action_just_pressed(&"flip") and coyote_timer > 0:
		flip()
		coyote_timer = 0
		return

	if Input.is_action_just_pressed(&"jump") and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY * (-1 if flipped else 1)
		coyote_timer = 0
		player_sfx_player.play_sfx(SFX.jumping)
	elif Input.is_action_just_pressed(&"reset"):
		Global.game_manager.respawn()
	elif Input.is_action_just_pressed(&"interact"):
		for lever in close_levers:
			lever.toggle()

func _handle_movement() -> void:
	last_direction = Input.get_axis("move_left", "move_right")
	if last_direction:
		velocity.x = last_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func _on_landed() -> void:
	if player_sfx_player.stream == SFX.flip and player_sfx_player.playing:
		return
	player_sfx_player.play_sfx(SFX.landing)

func _update_animations() -> void:
	if in_flipping_animation:
		return

	if last_direction > 0:
		sprite.scale.x = 1
	elif last_direction < 0:
		sprite.scale.x = -1

	if is_on_ground():
		if abs(velocity.x) > 0:
			if sprite.animation != "walking":
				sprite.play("walking")

			# Only play walking SFX if no other SFX is playing
			if player_sfx_player.stream == SFX.walking or not player_sfx_player.playing:
				player_sfx_player.play_sfx(SFX.walking)
		else:
			if sprite.animation != "idle":
				sprite.play("idle")
			if player_sfx_player.stream == SFX.walking:
				player_sfx_player.stop_sfx()
	else:
		var vertical_velocity := velocity.y * (-1 if flipped else 1)
		if vertical_velocity < 0:
			if sprite.animation != "jumping":
				sprite.play("jumping")
		else:
			if sprite.animation != "falling":
				sprite.play("falling")

		if player_sfx_player.stream == SFX.walking:
			player_sfx_player.stop_sfx()

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	in_flipping_animation = false

func _on_kill_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		Global.game_manager.respawn()


func _on_lever_area_entered(area: Area2D) -> void:
	if area is Lever:
		close_levers.append(area)

func _on_lever_area_exited(area: Area2D) -> void:
	if area is Lever:
		close_levers.erase(area)
