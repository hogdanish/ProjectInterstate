class_name Main
extends Node

var menu_music_tween
var mute_tween

var muted_manually := false
var muted := false

@export var menu_background_map : PackedScene
var player: Player = null

#func _process(delta: float) -> void
#	match current_state:



func _on_player_dead():
	Globals.focus = Globals.Focus.DEATH

func stop_game():
	cleanup_game()
	Globals.focus = Globals.Focus.MENU

func cleanup_game():
	print("Cleaning up game instance")
	if Globals.game:
		Globals.game.queue_free()
	else:
		print("Trying to free a non-existing game instance")

func free_title_menu() -> void:
	for i in get_tree().get_nodes_in_group(&"TitleMenu"):
		i.queue_free()
		await i.tree_exited

func spawn_game(threaded_map_loading := false):
	print(ConsoleLogger.bbcode_to_ansi("[color=dark_yellow][AppState.gd][color=yellow]"))
	print(ConsoleLogger.bbcode_to_ansi("Spawning game instance with threaded_map_loading = [color=dark_yellow]" + str(threaded_map_loading)))
	
	# Initialize game instance and enable threaded map loading depending on settings
	var game = load("res://Game/Game.tscn").instantiate()
	game.threaded_map_loading = threaded_map_loading
	
	# Update global game instance values
	Globals.game = game
	Globals.game.name = "Game"
	
	# Get root and spawn game instance
	get_tree().root.call_deferred(&"add_child", Globals.game)
	print(ConsoleLogger.bbcode_to_ansi("[color=yellow]Game instance added to SceneTree."))
	
	free_title_menu()
	await Globals.game.map_spawned  # wait for the map
	await get_tree().create_timer(1).timeout # delay
	
	print("Attempting to spawn player...")
	Globals.game.spawn_player()
	Globals.player_dead.connect(_on_player_dead)
	await Globals.game.player_spawned # wait for the player

func _ready():
	print(ConsoleLogger.bbcode_to_ansi("[color=dark_yellow][Main.gd][color=yellow]"))
	print ("Main.tscn successfully initialized.")
	get_tree().root.title = "MS Paint Interstate"
	Globals.focus = Globals.Focus.MENU
	Globals.focus_changed.connect(_on_focus_changed)
	if Settings.get_var(&'menu_background'):
		var bg_map = menu_background_map.instantiate()
		$TitleMenu.add_child(bg_map)
		bg_map.name = "BackgroundMap"
		if bg_map:
			print("Background map loadeded!")

func _on_focus_changed(new, previous):
	pass
	if new == Globals.Focus.PAUSE:
		$PauseMenu.show()
	else:
		$PauseMenu.hide()
	if new == Globals.Focus.DEATH:
		$DeathMenu.show()
	else:
		$DeathMenu.hide()

func _unhandled_key_input(event: InputEvent):
	
	# If cancel is pressed while in-game
	if event.is_action_pressed("ui_cancel") and Globals.game: # Escape
		
		# and pause menu is open, try to bring the focus back to where it was before.
		if Globals.focus == Globals.Focus.PAUSE and Globals.focus_previous != Globals.Focus.PAUSE:
			Globals.focus = Globals.focus_previous

		# and pause menu is closed, open up the pause menu.
		elif Globals.focus != Globals.Focus.PAUSE:
			Globals.focus = Globals.Focus.PAUSE
		
		get_tree().root.set_input_as_handled()

	elif event.is_action_pressed("in_quit"):
		get_tree().quit()

func _on_button_pressed() -> void:
	get_tree().quit()
