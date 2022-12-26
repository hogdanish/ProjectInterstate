@tool
extends State

func _on_update(_delta: float) -> void:
	
	if Input.is_action_just_pressed("jump"):
		choose_jump()

func choose_jump():
	if is_active("InAir"):
		var _st = change_state("DoubleJump")
	elif is_active("OnGround"):
		var _st = change_state("GroundJump")
