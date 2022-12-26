@tool
extends State

func _on_update(_delta) -> void:
	if Input.is_action_pressed("jump"):
		change_state("GroundJump")
