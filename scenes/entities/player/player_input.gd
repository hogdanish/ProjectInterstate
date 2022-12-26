extends PlayerShared
class_name PlayerInput

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if !locked:
			InputMouse(event)

#	if Input.is_action_just_pressed("in_lclick") and held_object != null:
		#Events.emit_signal("player_charge")

	#Object Pickup
#	if Input.is_action_just_pressed("in_interact"):
#		if held_object == null:
#			GrabObject()
#		elif held_object != null:
#			RemoveObject()

	#Object Rotating
#	if Input.is_action_pressed("in_rclick"):
#		if held_object != null:
#			locked = true
#			RotateObject(event)
#	if Input.is_action_just_released("in_rclick"):
#		locked = false
		
	#Crouching	
	if Input.is_action_pressed("move_crouch"):
		crouching = true
	elif Input.is_action_just_released("move_crouch"):
		crouching = false
	
	#Sprinting	
	if Input.is_action_pressed("in_lshift"):
		sprinting = true
	elif Input.is_action_just_released("in_lshift"):
		sprinting = false

#Object inputs
func GrabObject():
	pass
#	if coll != null and "targeted" in coll.get_parent():
#		if held_object == null and coll.get_parent().targeted:
#			strength = 0.0
#			held_object = coll
#			#Events.emit_signal("player_grab")
#			joint.set_node_b(held_object.get_path())
			
func RemoveObject():
	pass
#	if held_object != null:
#		held_object = null
#		Events.emit_signal("player_drop")
#		joint.set_node_b(joint.get_path())

func RotateObject(event):
	pass
#	if held_object != null:
#		if event is InputEventMouseMotion:
#			staticbody.rotate_x(deg_to_rad(event.relative.y * rotation_power))
#			staticbody.rotate_y(deg_to_rad(event.relative.x * rotation_power))	

#Process (Executed once per frame)
func _process(delta: float) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		InputKeys()
		ViewAngles(delta)

#Throwing
#	if held_object != null:
#		if Input.is_action_pressed("in_lclick"):
#			strength = min(max_strength, strength + delta * strength_speed)
#			#print (strength)
#			if strength != max_strength:
#				pass
#			if strength == max_strength and !has_been_capped:
#				_cap()
#				has_been_capped = true
#			if Input.is_action_pressed("in_interact"):
#				Events.emit_signal("player_drop")
#				has_been_capped = false
#				RemoveObject()
#		elif Input.is_action_just_released("in_lclick"):
#			Events.emit_signal("player_release")
#			has_been_capped = false
#			release_object()

#func _cap():
#	Events.emit_signal("player_charge_cap")
#
#func release_object() -> void:
#	var dir = (hand.global_transform.basis.z.normalized()) * -1 * strength + Vector3(0,5,0)
#	joint.set_node_b(joint.get_path())
#	Events.emit_signal("player_throw", dir)
#	held_object = null
#
#func reset_hand() -> void:
#	#hand_ik.stop()
#	strength = 0.0

		
#Mouse movement	
func InputMouse(event):
	if alive:
		xlook += -event.relative.y * ply_xlookspeed 
		ylook += -event.relative.x * ply_ylookspeed
		xlook = clamp(xlook, ply_maxlookangle_down, ply_maxlookangle_up)

func ViewAngles(_delta):
	camera.rotation.x = deg_to_rad(xlook)
	camera.rotation.y = deg_to_rad(ylook)
	
func InputKeys():
	sidemove += int(ply_sidespeed) * (int(Input.get_action_strength(&'move_left') * 50))
	sidemove -= int(ply_sidespeed) * (int(Input.get_action_strength(&'move_right') * 50))
	
	forwardmove += int(ply_forwardspeed) * (int(Input.get_action_strength(&'move_forward') * 50))
	forwardmove -= int(ply_backspeed) * (int(Input.get_action_strength(&'move_back') * 50))
	
	# Clamping to prevent high values
	if Input.is_action_just_released(&'move_left') or Input.is_action_just_released(&'move_right'):
		sidemove = 0
	else:
		sidemove = clamp(sidemove, -4096, 4096)
	if Input.is_action_just_released(&'in_up') or Input.is_action_just_released(&'in_down'):
		upmove = 0
	else:
		upmove = clamp(upmove, -4096, 4096)
	if Input.is_action_just_released(&'move_forward') or Input.is_action_just_released(&'move_back'):
		forwardmove = 0
	else:
		forwardmove = clamp(forwardmove, -4096, 4096)
