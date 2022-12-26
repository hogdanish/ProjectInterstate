@tool
extends State


#func _on_enter(_args) -> void:
#	jump()
# This function is called each frame if the state is ACTIVE
# XSM updates the root first, then the children
func _on_update(_delta: float) -> void:
	if Input.is_action_pressed("jump"):
		jump()
	
	
	
func jump():
	target.snap = Vector3.ZERO
	
	#Events.emit_signal("player_jump")
	var flGroundFactor = 1.0
	var flMul = sqrt(2 * target.ply_gravity * target.ply_jumpheight)
	target.vel.y += flGroundFactor * flMul  # 2 * gravity * height
	
	# Add a little forward velocity based checked your current forward velocity - if you are not sprinting.
	var vel2d = Vector2(target.vel.x, target.vel.z)
	var vecforward = Vector3.FORWARD
	vecforward = vecforward.rotated(Vector3.UP, target.camera.rotation.y)
	vecforward.y = 0
	vecforward = vecforward.normalized()
	# We give a certain percentage of the current forward movement as a bonus to the jump speed.  That bonus is clipped
	# to not accumulate over time.
	var flSpeedBoostPerc = 1.5
	var flSpeedAddition = abs(target.forwardmove * flSpeedBoostPerc)
	var flMaxSpeed = target.ply_maxspeed * flSpeedBoostPerc
	var flNewSpeed = flSpeedAddition + vel2d.length()

	# If we're over the maximum, we want to only boost as much as will get us to the goal speed
	if flNewSpeed > flMaxSpeed:
		flSpeedAddition -= flNewSpeed - flMaxSpeed

	if target.forwardmove < 0:
		flSpeedAddition *= -1.0

	# Add it checked
	target.vel += vecforward * flSpeedAddition

