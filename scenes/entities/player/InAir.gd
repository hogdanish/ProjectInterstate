@tool
extends State

var ply_gravity = 120
@export var double_jump_warmup := 0.1

func _on_enter(_args) -> void:
	add_timer("Double", double_jump_warmup)
	
	if target.is_on_floor():
		change_state("OnGround")
		change_state("NoDoubleJump")

func _on_timeout(_double):
	if not target.is_on_floor():
		change_state("CanDoubleJump")

func _on_update(delta: float) -> void:
	if target.is_on_floor():
		change_state("OnGround")

	var forward = Vector3.FORWARD
	var side = Vector3.LEFT
	
	forward = forward.rotated(Vector3.UP, target.camera.rotation.y)
	side = side.rotated(Vector3.UP, target.camera.rotation.y)
	
	forward = forward.normalized()
	side = side.normalized()
	
	var fmove = target.forwardmove
	var smove = target.sidemove
	
	target.snap = Vector3.ZERO
	target.vel.y -= target.ply_gravity * delta
	
	var wishvel = side * smove + forward * fmove
	
	# Zero out y value
	wishvel.y = 0
	
	var wishdir = wishvel.normalized()
	# VectorNormalize in the original source code doesn't actually return the length of the normalized vector
	# It returns the length of the vector before it was normalized
	var wishspeed = wishvel.length()
	
	# clamp to game defined max speed
	if wishspeed != 0.0 and wishspeed > target.ply_maxspeed:
		wishvel *= target.ply_maxspeed / wishspeed
		wishspeed = target.ply_maxspeed
	
	var accel = target.ply_accelerate
	
	wishspeed = min(wishspeed, target.ply_airspeedcap)
	# See if we are changing direction a bit
	var currentspeed = target.vel.dot(wishdir)
	# Reduce wishspeed by the amount of veer.
	var addspeed = wishspeed - currentspeed
	
	# If not going to add any speed, done.
	if addspeed <= 0:
		return

	# Determine amount of accleration.
	var accelspeed = accel * wishspeed * delta 
	
	# Cap at addspeed
	accelspeed = min(accelspeed, addspeed)
	
	for i in range(3):
		# Adjust velocity.
		target.vel += accelspeed * wishdir
	
	target.top.set_disabled(false)
	target.bottom.set_disabled(false)
