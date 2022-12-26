@tool
extends State

func _on_update(_delta):
	if Input.is_action_pressed("jump"):
		change_state("DoubleJump")
