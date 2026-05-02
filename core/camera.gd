class_name GlobalCamera
extends Camera2D

var copy_node: Node2D = null
var offset_to_copy_node: Vector2 = Vector2.ZERO

var shake_intensity: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

func _process(_delta: float) -> void:
	var base := (copy_node.global_position - offset_to_copy_node) if copy_node else Vector2.ZERO
	var shake := Vector2.ZERO
	if shake_intensity > 0.0:
		shake = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake_intensity
	offset = base + shake

func translate_with_node(node: Node2D, _offset = Vector2.ZERO):
	copy_node = node
	offset_to_copy_node = _offset
	process_mode = Node.PROCESS_MODE_INHERIT

func stop_translations():
	copy_node = null
	offset_to_copy_node = Vector2.ZERO
	_update_processing()

func start_shake(intensity: float = 3) -> void:
	shake_intensity = intensity
	process_mode = Node.PROCESS_MODE_INHERIT

func stop_shake() -> void:
	shake_intensity = 0.0
	_update_processing()

func _update_processing() -> void:
	if copy_node == null and shake_intensity <= 0.0:
		process_mode = Node.PROCESS_MODE_DISABLED
		offset = Vector2.ZERO
