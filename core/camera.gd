class_name GlobalCamera
extends Camera2D

var copy_node: Node2D = null
var offset_to_copy_node: Vector2 = Vector2.ZERO

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

func _process(delta: float) -> void:
	offset = copy_node.global_position - offset_to_copy_node

func translate_with_node(node: Node2D):
	copy_node = node
	offset_to_copy_node = node.global_position
	process_mode = Node.PROCESS_MODE_INHERIT

func stop_translations():
	process_mode = Node.PROCESS_MODE_DISABLED
	copy_node = null
	offset_to_copy_node = Vector2.ZERO
