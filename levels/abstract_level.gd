class_name AbstractLevel
extends Node2D

signal won

enum Level {
	Start,
	Tower,
	Pillars,
	TheFall,
	Wall,
	Spikes,
	Door,
	Floor,
	Clouds,
	PathOfPain,
	LeverIntro,
	Lever,
	Cave,
	Climbing,
	Portal,
	End,
	Cycle_Top,
	Cycle_Bot,
	White_Lever
}

@onready var tile_map_layer: TileMapLayer = $TileMapLayer

var entrances: Array[LevelEntrance] = []
var levers: Array[Lever] = []

func _ready() -> void:
	for entrance in find_children("", "LevelEntrance"):
		entrances.append(entrance)
	for lever in find_children("", "Lever"):
		levers.append(lever)


func _on_rocket_start() -> void:
	won.emit()
