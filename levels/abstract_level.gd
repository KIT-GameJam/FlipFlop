class_name AbstractLevel
extends Node2D

enum Level {
	Start,
	Tower,
	Pillars,
	TheFall,
}

var entrances: Array[Vector2] = []

func _ready() -> void:
	for entrance in find_children("", "LevelEntrance"):
		entrances.append(entrance.position)
