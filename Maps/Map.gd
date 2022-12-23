extends Node3D

@onready var player_spawn = $PlayerSpawn

func get_spawnpoint() -> Transform3D:
	return player_spawn.get_child(randi() % player_spawn.get_child_count()).global_transform
