extends Node

signal var_changed(var_name, value)

var settings = {} # current game settings

var settings_dir = "user://settings/"
var settings_file_path = settings_dir + "settings.liblast"
var settings_last = {} # copy of last settings for undo

var presets_dir = "res://settings/presets/"
var presets = {} # a dictionary of var_name presets. preset : settings{}

var dirty = false # have the settings been altered?

const SAVE_WAIT_TIME : float = 3 # how many seconds to wait between saving preferences

var save_timer : float = 0 # timer to limit disk writes when settings are changed rapidly

# DEFAULTS

const settings_default = {
	'player_first_run' = true,
	'display_fullscreen' = false,
	'menu_background' = true,
	'audio_volume_master' = 10,
	}


#func _init():
func _ready() -> void:
	set_physics_process(false)
#	print_debug("Initialising settings manager: ", self)
	# ensure the settings directory exists
	var dir = DirAccess.open(settings_dir)
	if not dir:
#		print_debug("Creating settings directory: ",\
#			error_string(DirAccess.make_dir_recursive_absolute(settings_dir)))
		dir = DirAccess.open(settings_dir)

	load_settings()

	call_apply_all()

# SAVE/LOAD

func _physics_process(delta: float) -> void:
#	print(save_timer)
	if save_timer > 0:
		save_timer = max(0, save_timer - delta)
		if save_timer == 0:
#			print("FFF")
			if dirty:
				save_settings()
	else:
		set_physics_process(false)


# TODO: Unify the type of the return value
func save_settings(force = false):
	if save_timer > 0 and not force:
		set_physics_process(true)
		return

	if not dirty and not force:
#		print_debug("Attempted to save unmodified settings, skipping")
		return ERR_ALREADY_EXISTS
#	elif not dirty and force:
#		print_debug("Forced saving unmodified settings")
#	else:
#		print_debug("Saving dirty settings")

	var settings_changed = {}

	for i in settings_default.keys():
		if settings.keys().has(i):
#			if (settings_default[i] is String and not settings[i] is String) or\
#			(not settings_default[i] is String and settings[i] is String):
#				print("Incompatible variable types")
#			else:

#			print("Comparing var ", settings[i], " with default value ", settings_default[i])
#			print("Comparing var ", i , " of value ", settings[i], " with default value ", settings_default[i])
			# Due to an obscure Godot bug both values are printed (and compared) as being the same,
			# despite settings_default being a constant and the setting value being clearly different.
			# Happy debugging. Read more here: https://codeberg.org/Liblast/Liblast/issues/354
			if settings[i] != settings_default[i]:
#					prints("Variable ", i, "is not using default value - SAVING")
					settings_changed[i] = settings[i]
#				else:
#					prints("Variable", i, "is using default value - not saving.")
#			else:
#				prints("Setting", i, "is of different type than default - not saving.")

	if settings_changed.is_empty():
		print_debug("Settings were NOT saved! This might be a known Godot bug. See here: https://codeberg.org/Liblast/Liblast/issues/354")
		return

	if not DirAccess.dir_exists_absolute(settings_dir):
		DirAccess.make_dir_recursive_absolute(settings_dir)

	var file = FileAccess.open(settings_file_path, FileAccess.WRITE)
	if file == null:
		print_debug("Cannot open file for writing")
		return

#	print("Variables changed: ", settings_changed)

	file.store_string(var_to_str(settings_changed))
	if file.get_error():
		return file.get_error()
	file.flush()

#	print_debug("Settings saved")
	dirty = false
	save_timer = SAVE_WAIT_TIME # set timer
	set_physics_process(true)
	return OK


func load_settings():
	var file = FileAccess.open(settings_file_path, FileAccess.READ)

	if file:
		var settings_loaded = str_to_var(file.get_as_text())
		if settings_loaded is Dictionary: # overlay the file contents over defaults
			for i in settings_default.keys():
				if settings_loaded.has(i):
#					prints("Setting", i, "present. Overriding default value.")
					settings[i] = settings_loaded[i]
				else:
					settings[i] = settings_default[i]
#					prints("Setting", i, "missing. Using default.")

		else:
			print_debug("Settings file contains invalid data")
			return ERR_INVALID_DATA
	else:
		print_debug("Cannot load settings file. Using defaults.")
		settings = settings_default
		return ERR_FILE_CANT_OPEN

	return OK

# SET/GET


func set_var(var_name: String, value: Variant) -> int:
	if value == null:
		return ERR_INVALID_DATA

	if not dirty:
		dirty = true
	settings[var_name] = value
	emit_signal(&'var_changed', var_name, value)
	call_apply_var(var_name)
	save_settings()

	return OK
#	print_debug("Variable ", var_name, " was set to ", value)


func get_var(var_name: String) -> Variant: # return a given var_name
	return settings.get(var_name)


# APPLY


func call_apply_var(var_name: String) -> void: # call function corresponding to the given var_name
	var apply_method: StringName = StringName("apply_" + var_name)
	if has_method(apply_method):
		call(apply_method, settings[var_name])
#	else:
#		printerr("Settings var_name ", var_name, " has no apply method")


func call_apply_all(): # apply all current settings
	for key in settings.keys():
		call_apply_var(key)


func load_preset(preset: String) -> void: # load var_names from a preset
	settings_last = settings
	settings = presets[preset]


func restore_last() -> void:
	settings = settings_last

### VARIABLE APPLY FUNCTIONS

#func apply_player_name(value:String) -> void:
#		print_debug("Setting player name to ", value)


func apply_display_fullscreen(value:bool) -> void:
	if value:
		get_viewport().mode = Window.MODE_FULLSCREEN
	else:
		get_viewport().mode = Window.MODE_WINDOWED
#		get_viewport().mode = Window.MODE_MAXIMIZED

func apply_audio_volume_master(value) -> void:
#	print_debug("Setting master volume to ", value)
	AudioServer.set_bus_volume_db(0, value)
