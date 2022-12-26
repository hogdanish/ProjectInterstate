@tool
extends State

func _on_enter(_args) -> void:
	change_state("Grounded")

func _on_update(delta: float) -> void:
	var forward = Vector3.FORWARD
	var side = Vector3.LEFT
	
	forward = forward.rotated(Vector3.UP, target.camera.rotation.y)
	side = side.rotated(Vector3.UP, target.camera.rotation.y)
	
	forward = forward.normalized()
	side = side.normalized()
	
	target.snap = -target.get_floor_normal()
	
	var fmove = target.forwardmove
	var smove = target.sidemove
	
	var wishvel = side * smove + forward * fmove
	
	var speed : float = target.vel.length()
	
	# If too slow, return
	if speed < 0:
		return

	var drop = 0

	# apply ground friction
	var friction = target.ply_friction

	# Bleed unchecked some speed, but if we have less than the bleed
	#  threshold, bleed the threshold amount.
	var control : float = target.ply_stopspeed if speed < target.ply_stopspeed else speed
	# Add the amount to the drop amount.
	drop += control * friction * delta

	# scale the velocity
	var newspeed = speed - drop
	if newspeed < 0:
		newspeed = 0

	if newspeed != speed:
		# Determine proportion of old speed we are using.
		newspeed /= speed
		# Adjust velocity according to proportion.
		target.vel *= newspeed
	
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
