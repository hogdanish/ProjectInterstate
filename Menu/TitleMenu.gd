extends Control

var menu_map : Node3D:
	set(value):
		menu_map = value

func _on_start_pressed():
	#set_process(true)
	if not is_instance_valid(Globals.game_state):
		Globals.main.spawn_game_state()
	#set_process(false)
