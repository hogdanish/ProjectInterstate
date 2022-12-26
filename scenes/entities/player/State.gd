@tool
extends State

func _on_enter(_args) -> void:
	if target.is_on_floor():
		change_state("OnGround")
	else:
		change_state("InAir")

func _on_update(_delta):
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		InputKeys()
	
	if target.vel.length() > target.ply_maxvelocity:
		target.vel = target.ply_maxvelocity
	elif target.vel.length() < -target.ply_maxvelocity:
		target.vel = -target.ply_maxvelocity
	
	target.set_velocity(target.vel)
	target.set_floor_snap_length(0.1)
	target.set_up_direction(Vector3.UP)
	target.set_floor_stop_on_slope_enabled(true)
	target.set_max_slides(4)
	target.set_floor_max_angle(target.ply_maxslopeangle)
	target.move_and_slide()
	target.vel = target.velocity
	
	if target.is_on_floor():
		change_state("OnGround")
	else:
		change_state("InAir")

func InputKeys():
	target.sidemove += int(target.ply_sidespeed) * (int(Input.get_action_strength(&'move_left') * 50))
	target.sidemove -= int(target.ply_sidespeed) * (int(Input.get_action_strength(&'move_right') * 50))
	
	target.forwardmove += int(target.ply_forwardspeed) * (int(Input.get_action_strength(&'move_forward') * 50))
	target.forwardmove -= int(target.ply_backspeed) * (int(Input.get_action_strength(&'move_back') * 50))
	
	# Clamping to prevent high values
	if Input.is_action_just_released(&'move_left') or Input.is_action_just_released(&'move_right'):
		target.sidemove = 0
	else:
		target.sidemove = clamp(target.sidemove, -4096, 4096)
	if Input.is_action_just_released(&'in_up') or Input.is_action_just_released(&'in_down'):
		target.upmove = 0
	else:
		target.upmove = clamp(target.upmove, -4096, 4096)
	if Input.is_action_just_released(&'move_forward') or Input.is_action_just_released(&'move_back'):
		target.forwardmove = 0
	else:
		target.forwardmove = clamp(target.forwardmove, -4096, 4096)
