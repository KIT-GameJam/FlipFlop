class_name Player
extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var flipped = false

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _ready():
	sprite.modulate = Color.BLACK

func flip():
	if flipped:
		_flip_up()
	else:
		_flip_down()
	flipped = !flipped

func is_on_ground():
	return (is_on_ceiling() if flipped else is_on_floor())

func _flip_up():
	animation_player.play("flip_up")
	collision_shape.position = Vector2(0, -40)
	set_collision_mask_value(3, true)
	set_collision_mask_value(2, false)

func _flip_down():
	animation_player.play("flip_down")
	collision_shape.position = Vector2(0, 40)
	set_collision_mask_value(2, true)
	set_collision_mask_value(3, false)

func _physics_process(delta: float) -> void:
	var on_ground = is_on_ground()
	# Add the gravity.
	if not on_ground:
		velocity += get_gravity() * delta * (-1 if flipped else 1)
	
	if Input.is_action_just_pressed("jump") and on_ground:
		velocity.y = JUMP_VELOCITY * (-1 if flipped else 1)
	elif Input.is_action_just_pressed("flip") and on_ground:
		flip()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
