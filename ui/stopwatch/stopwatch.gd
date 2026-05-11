class_name Stopwatch
extends Node

@export var auto_start: bool = false

var running: bool = false
var elapsed_time: float = 0.0

func _ready() -> void:
	if auto_start:
		start()

func _process(delta: float) -> void:
	if running:
		elapsed_time += delta

func start() -> void:
	elapsed_time = 0.0
	running = true

func stop() -> void:
	running = false
