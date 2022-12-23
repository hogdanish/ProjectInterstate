extends Control

var menu_map : Node3D:
	set(value):
		menu_map = value

func _on_start_pressed():
	#set_process(true)
	if not is_instance_valid(Globals.game):
		Globals.main.spawn_game()
	#set_process(false)
