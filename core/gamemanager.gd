extends Node
class_name GameManager

## Use this when you have only one level
@export var main_level := AbstractLevel.Level.Start
## Whether the mouse should be captured while in a level
@export var is_mouse_captured_in_level: bool = true

@onready var pause_menu: Control = %PauseMenu
@onready var menu_layer: CanvasLayer = %MenuLayer

const LEVELS: Dictionary[AbstractLevel.Level, PackedScene] = {
	AbstractLevel.Level.Start: preload("res://levels/level_start.tscn"),
	AbstractLevel.Level.Wall: preload("res://levels/level_tower.tscn"),
	AbstractLevel.Level.Pillars: preload("res://levels/level_pillars.tscn"),
	AbstractLevel.Level.TheFall: preload("res://levels/level_the_fall.tscn"),
}
var loaded_levels: Dictionary[AbstractLevel.Level, AbstractLevel] = {}

var current_level: AbstractLevel.Level
var current_level_node: AbstractLevel

const PlayerScene = preload("res://entities/Player.tscn")
var player: Player

func _ready() -> void:
	Global.set_game_manager(self)
	DebugGlobal.debug_label = %DebugLabel

	# Settings
	var user_settings = UserDefinedSettings.new()
	user_settings._register_settings()
	Settings.load_config()

	# Connect to InputManager
	InputManager.game_pause.connect(pause)
	InputManager.game_unpause.connect(resume)
	InputManager.capture_mouse_ingame = is_mouse_captured_in_level
	InputManager.set_is_in_game(false)
	InputManager.set_is_paused(false)

	_show_title_screen()

func _start_game() -> void:
	_show_controls()

#region Pausing

func pause():
	InputManager.set_is_paused(true)
	move_child(menu_layer, -1)
	pause_menu.move_to_front()
	pause_menu.show()
	get_tree().paused = true

func resume():
	InputManager.set_is_paused(false)
	print("resume")
	pause_menu.hide()
	pause_menu.reset()
	get_tree().paused = false
#endregion

#region Level Loading

func _show_main_level() -> void:
	if main_level == null:
		push_error("main_level is not set in GameManager")
		return

	if not player:
		player = PlayerScene.instantiate()
		add_child(player)

	InputManager.set_is_in_game(true)
	loaded_levels.clear()
	for level in LEVELS:
		loaded_levels[level] = LEVELS[level].instantiate()
	change_level(main_level, 0)

func change_level(new_level: AbstractLevel.Level, entrance: int) -> void:
	# disable player collision to prevent interactions with new level
	player.hit_box.set_deferred("disabled", true)
	var collision_layer := player.collision_layer
	player.collision_layer = 0
	var collision_mask := player.collision_mask
	player.collision_mask = 0

	if new_level != current_level or current_level_node == null:
		if current_level_node != null:
			remove_child.call_deferred(current_level_node)
		current_level = new_level
		current_level_node = loaded_levels[current_level]
		add_child.call_deferred(current_level_node)
	await get_tree().process_frame
	player.position = current_level_node.entrances[entrance]

	# wait for one frame before enabling collision again
	await get_tree().process_frame
	player.hit_box.disabled = false
	player.collision_layer = collision_layer
	player.collision_mask = collision_mask


#endregion

#region Showing Different GUI views

func _show_win_screen() -> void:
	InputManager.set_is_in_game(false)
	var win_screen: Control = load("res://ui/screens/win-screen/win_screen.tscn").instantiate()
	win_screen.tree_exited.connect(_show_title_screen)
	add_child(win_screen)

func _show_credits() -> void:
	var credits: Node = load("res://ui/screens/credit-screen/credit_screen.tscn").instantiate()
	credits.tree_exited.connect(_show_title_screen)
	menu_layer.add_child(credits)

func _show_title_screen() -> void:
	InputManager.set_is_in_game(false)
	var title_screen: Node = load("res://ui/screens/title-screen/title_screen.tscn").instantiate()
	title_screen.start_game.connect(_start_game)
	title_screen.show_credits.connect(_show_credits)
	title_screen.show_settings_screen.connect(_show_settings_screen)
	title_screen.quit.connect(_quit_game)
	menu_layer.add_child(title_screen)

func _show_settings_screen() -> void:
	var settings_screen: Node = load("res://ui/screens/settings-screen/settings_screen.tscn").instantiate()
	settings_screen.exit.connect(_show_title_screen)
	menu_layer.add_child(settings_screen)

func _show_controls() -> void:
	var controls: Node = load("res://ui/screens/control-screen/control_screen.tscn").instantiate()
	controls.tree_exited.connect(_show_main_level)
	menu_layer.add_child(controls)

func _return_to_title_screen() -> void:
	get_tree().paused = false
	InputManager.set_is_paused(false)
	InputManager.set_is_in_game(false)

	# Destroy levels
	for level in loaded_levels.values():
		level.queue_free()
	loaded_levels.clear()
	current_level_node = null

	# Destroy player
	if player != null:
		player.queue_free()
		player = null

	_show_title_screen()

#endregion

func _quit_game() -> void:
	get_tree().paused = false
	get_tree().quit()

func set_world_environment(env: Environment):
	$WorldEnvironment.environment = env
