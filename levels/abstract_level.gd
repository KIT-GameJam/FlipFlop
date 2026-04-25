class_name AbstractLevel
extends Node2D

enum Level {
	Start,
	Tower,
	Pillars,
	TheFall,
	Wall,
	Spikes,
	TinyDoor,
	Floor,
	Clouds,
	PathOfPain,
}

var entrances: Array[LevelEntrance] = []

func _ready() -> void:
	for entrance in find_children("", "LevelEntrance"):
		entrances.append(entrance)
