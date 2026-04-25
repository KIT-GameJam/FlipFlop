class_name AbstractLevel
extends Node2D

enum Level {
	Level1,
	Level2,
}

var entrances: Array[Vector2] = []

func _ready() -> void:
	for entrance in find_children("", "Marker2D"):
		entrances.append(entrance.position)
