extends Node

var player: Player = null

func spawn_game_state(threaded_map_loading := false):
	print(ConsoleLogger.bbcode_to_ansi("[color=dark_yellow][AppState.gd][color=yellow]"))
	print(ConsoleLogger.bbcode_to_ansi("Spawning game state with threaded_map_loading = [color=dark_yellow]" + str(threaded_map_loading)))
	
	# Initialize game state and enable threaded map loading depending on settings
	var game_state = load("res://Game/GameState.tscn").instantiate()
	game_state.threaded_map_loading = threaded_map_loading
	
	# Update global game state values
	Globals.game_state = game_state
	Globals.game_state.name = "GameState"
	
	# Get root and spawn game state
	get_tree().root.call_deferred(&"add_child", Globals.game_state)
	print(ConsoleLogger.bbcode_to_ansi("[color=yellow]Game state added to SceneTree."))
	#return game_state
	
	#free_title_menu()
	#await Globals.game_state.map_spawned  # wait for the map
	#await get_tree().create_timer(1).timeout # delay
	
	print("Attempting to spawn player...")
	#Globals.game_state.spawn_player()
	#Globals.player_dead.connect(_on_player_dead)
	#await Globals.game_state.player_spawned # wait for the player

func _on_player_dead():
	Globals.focus = Globals.Focus.DEATH

func stop_game():
	cleanup_game_state()
	Globals.focus = Globals.Focus.MENU

func cleanup_game_state():
	print("Cleaning up game state")
	if Globals.game_state:
		Globals.game_state.queue_free()
	else:
		print("Trying to free a non-existing GameState")

func free_title_menu() -> void:
	for i in get_tree().get_nodes_in_group(&"TitleMenu"):
		i.queue_free()
		await i.tree_exited
	
