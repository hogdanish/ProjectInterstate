extends Node

enum Focus {MENU, PAUSE, DEATH, GAME}

signal focus_changed(new: Focus, previous: Focus)
signal player_loaded(player:CharacterBody3D)
signal player_dead

var game : Game
var main : Main

var player: Player = null:
	set(value):
		if value == player:
#			print_debug("Attempting to set exisitng current_character; skipping")
			return
		player_loaded.emit(player)

# if something new is focused
var focus: Focus = Focus.MENU: # menu is default
	set(value):
		prints("Focus changed to", value, "a.k.a", Focus.keys()[value])
		if value == self.focus:
			return

		focus_previous = focus
		focus = value
		focus_changed.emit(focus, focus_previous)

		if value in [Focus.MENU, Focus.DEATH, Focus.PAUSE]: # if these are focused
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # set mouse mode visible
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


		#if value in [Focus.PAUSE]: # if pause is focused
			#if Globals.game:
				#Globals.game.get_tree().paused # physically pause game
		#elif Globals.game:
			#!Globals.game.get_tree().paused
				

var focus_previous: Focus = focus
