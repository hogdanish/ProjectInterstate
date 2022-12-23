extends Node

enum Focus {MENU, PAUSE, DEATH, GAME, CONSOLE}

var game : Game
var main : Main
var console : Console

signal focus_changed(new: Focus, previous: Focus)
signal player_loaded(player:CharacterBody3D)
signal player_dead

var player: CharacterBody3D = null:
	set(value):
		if value == player:
#			print_debug("Attempting to set exisitng current_character; skipping")
			return
		player = value
		player_loaded.emit(player)

var focus: Focus = Focus.MENU:
	set(value):
		prints("Focus changed to", value, "a.k.a", Focus.keys()[value])
		if value == self.focus:
			return

		focus_previous = focus
		focus = value
		focus_changed.emit(focus, focus_previous)

		# make mouse cursor visible only in MENU, DEATH, PAUSE focus
		if value in [Focus.MENU, Focus.DEATH, Focus.PAUSE]:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
#		# pause the game state when in PAUSE focus
#		if value in [Focus.PAUSE]:
#			if Globals.game_state:
#				pass
#				#Globals.game_state.pause()
				

var focus_previous: Focus = focus
