extends Sprite3D

# Declare a variable to store the speed at which the object moves
var speed = 10
var growth_rate = 0.1

func _ready():
	set_process(false)
	Globals.player_loaded.connect(_on_player_loaded)

func _on_player_loaded(player: CharacterBody3D) -> void:
	if player:
		set_process(true)

# Use the _process function to update the object every frame
func _process(delta):
	var player_position : Vector3 = Globals.player.position
	position = position.move_toward(Vector3(player_position), delta * speed)
