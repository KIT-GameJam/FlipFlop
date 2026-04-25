class_name Lever
extends Area2D

@export var sprite_black := false
@export var toggle_blocks: Array[Vector2i]

@onready var sprite: Sprite2D = $Sprite2D
@onready var sfx_flip_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var toggled := false

const TILE_MAPPING: Dictionary[Array, Array] = {
	[0, Vector2i(0, 0)]: [0, Vector2i(0, 1)],
	[0, Vector2i(0, 1)]: [0, Vector2i(0, 0)],
	[0, Vector2i(0, 3)]: [0, Vector2i(1, 3)],
	[0, Vector2i(1, 3)]: [0, Vector2i(0, 3)],
	[0, Vector2i(2, 3)]: [0, Vector2i(3, 3)],
	[0, Vector2i(3, 3)]: [0, Vector2i(2, 3)],
}

func _ready() -> void:
	if sprite_black:
		modulate = Color.BLACK

func toggle() -> void:
	var tile_map: TileMapLayer = Global.game_manager.current_level_node.tile_map_layer
	for block in toggle_blocks:
		var source_id := tile_map.get_cell_source_id(block)
		var atlas_coords := tile_map.get_cell_atlas_coords(block)
		var mapping = TILE_MAPPING.get([source_id, atlas_coords])
		if mapping:
			tile_map.set_cell(block, mapping[0], mapping[1])
	toggled = not toggled
	sprite.scale.x *= -1
	if sfx_flip_player.playing:
		sfx_flip_player.stop()
	sfx_flip_player.play()

func reset() -> void:
	if toggled:
		toggle()
