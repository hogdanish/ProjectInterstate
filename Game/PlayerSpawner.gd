extends Node

func spawn_player():
	var player = load("res://Characters/Player/player.tscn").instantiate()
	self.add_child(player)
	player.global_transform = Globals.game_state.get_spawn_transform()
