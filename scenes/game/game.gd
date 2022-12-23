extends Node3D
class_name Game

signal map_loaded
signal map_spawned
signal player_spawned

@onready var player_spawner : Node
@export var player_spawner_path : NodePath
@export var map : Node3D

var threaded_map_loading : bool = false # Put in settings eventually

enum GameState {INIT, PLAY, PAUSE, CONSOLE}

func _ready():
	set_process(false) # Disable map loading loop
	if not map: # If there is no map node loaded:
		map_path = "res://scenes/game/maps/Map.tscn"
		print("Map path manually set to: ", map_path)

func _process(_delta: float) -> void:
#	match 
	
	if ResourceLoader.load_threaded_get_status(map_path) == ResourceLoader.THREAD_LOAD_LOADED:
		map_loaded.emit()

@export var map_path : String: # Triggered when map path is set
	set(value):
		if value == map_path:
			push_warning("Trying to load the same map again")
			return
		map_path = value
		if not map_path.is_empty(): # If map path isn't empty
			load_map(threaded_map_loading)

# Map loading
func load_map(threaded := false): 
	
	var map_resource : PackedScene
	print("Starting map loading in %s mode..." % ["threaded" if threaded else "blocking"] )
	var time = Time.get_ticks_msec()
	
	# Threaded loader
	if threaded:
		ResourceLoader.load_threaded_request(map_path, "PackedScene", true)
		set_process(true)
		await(map_loaded)
		set_process(false)
		map_resource = ResourceLoader.load_threaded_get(map_path)
	
	# Non-threaded loader
	else:
		map_resource = load(map_path)
	if not map_resource: # Fallback
		map_resource = load(map_path)

	time = Time.get_ticks_msec() - time
	prints("Map loaded in", time,"miliseconds")
	
	# Load the map resource into the map variable
	map = map_resource.instantiate()
	map.name = "Map"
	self.add_child(map)
	Globals.focus = Globals.Focus.GAME
	map_spawned.emit()

func get_spawn_transform() -> Transform3D:
	if map:
		var player_spawn : Marker3D = map.get_node(^"PlayerSpawn")
		return player_spawn.global_transform
	else:
		print_debug("Warning: spawning character before the map is spawned!")
		return Transform3D.IDENTITY

func spawn_player():
	var player = load("res://scenes/entities/player/Player.tscn").instantiate()
	player.name = "Player"
	self.add_child(player)
	player_spawned.emit()
	player.global_transform = get_spawn_transform()

func unpause():
	#animator.play("unpause")
	get_tree().paused = false

func pause():
	#animator.play("pause")
	get_tree().paused = true
