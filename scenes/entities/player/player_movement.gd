extends PlayerInput
class_name PlayerMovement

signal targeted(coll, coll_buffer)
signal buffer_untargeted(coll, coll_buffer)
signal player_hud_update(update: PlayerHudUpdate)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Globals.player = self

func _physics_process(delta: float) -> void:
	Move(delta)
	CrouchCamera()
	GrabbingPhysics()
	bobshit(delta)

func GrabbingPhysics():
	if held_object != null:
		var a = held_object.global_transform.origin
		var b = hand.global_transform.origin
		held_object.set_linear_velocity((b-a)*pull_power)

func CheckVelocity():
	if vel.length() > ply_maxvelocity:
		vel = ply_maxvelocity
			
	elif vel.length() < -ply_maxvelocity:
		vel = -ply_maxvelocity

func Move(delta):
	if crouching:
		#Crouching
		ply_maxspeed = ply_crouch_speed
		ply_stepspeed = ply_crouch_step_speed
		ply_friction = 4.5
		ply_airaccelerate = 3
	if sprinting and crouching:
		#Crouch-sprinting
		ply_maxspeed = ply_crouchsprint_speed
		ply_stepspeed = ply_crouchsprint_step_speed
		camera.set_fov(lerp(camera.fov, normal_fov * fov_multiplier, delta * 8))
		ply_friction = 2
		ply_airaccelerate = 6
	if sprinting and !crouching:
		#Sprinting
		ply_maxspeed = ply_sprint_speed
		ply_stepspeed = ply_sprint_step_speed
		camera.set_fov(lerp(camera.fov, normal_fov * fov_multiplier, delta * 8))
		ply_friction = 8
		ply_airaccelerate = 3
	elif !crouching and !sprinting:
		#Walking
		ply_maxspeed = ply_walk_speed
		ply_stepspeed = ply_walk_step_speed
		camera.set_fov(lerp(camera.fov, normal_fov, delta * 8))
		ply_friction = 4
		ply_airaccelerate = 3
		
	if is_on_floor():
		stopfuckingcrouchinginmidairyoufuckingcunt = false
		
	if !stopfuckingcrouchinginmidairyoufuckingcunt:
		Crouch()

	if noclip == true:
		NoclipMove(delta)
		
	elif is_on_floor() and noclip == false:
		WalkMove(delta)
	else:
		AirMove(delta)
		
	CheckVelocity()
	
	set_velocity(vel)
	# TODOConverter40 looks that snap in Godot 4.0 is float, not vector like in Godot 3 - previous value `snap`
	set_up_direction(Vector3.UP)
	set_floor_stop_on_slope_enabled(true)
	set_max_slides(4)
	set_floor_max_angle(ply_maxslopeangle)
	# TODOConverter40 infinite_inertia were removed in Godot 4.0 - previous value `false`
	move_and_slide()
	vel = velocity

func Crouch():
	# dumbest shit i ever coded
	if crouching and !is_on_floor() and Input.is_action_just_pressed("move_crouch"):
		var up = top.get_position(); var down = bottom.get_position();
		
		# FUCKING CROUCHJUMPING
		self.global_translate(Vector3(0, up.distance_to(down) / 2.5, 0))
		self.global_translate(Vector3(0, down.distance_to(up) / 2.5, 0))
		
		if !is_on_floor():
			stopfuckingcrouchinginmidairyoufuckingcunt = true
	
func CrouchCamera():
	
	# Crouching
	if crouching:
		crouched = true
	if !crouching:
		crouched = false
	
	if is_on_floor() and crouched:
		camera.position = camera.position.lerp(Vector3(0, ply_crouchedheight, 0), ply_crouchlerpweight)
	if is_on_floor() and !crouched:
		camera.position = camera.position.lerp(Vector3(0, ply_crouchstanceheight, 0), ply_crouchlerpweight)
	if !is_on_floor() and crouched:
		camera.position.y = ply_crouchedheight

func bobshit(delta):
	is_on_floor()
	var speed_clamped = remap(vel.length(), 0.0, ply_maxspeed, 0.0, 1.0)
	var grounded = float(is_on_floor())
	var slide : float
	t += delta * ply_stepspeed * speed_clamped * grounded
	var tcam_pos = Vector2(sin(t) * ply_cambob, cos(t * 0.5) * ply_cambob)
	if speed_clamped <= 0.1:
		t = 0.0
		tcam_pos = Vector2.ZERO
	cam_pos = lerp(cam_pos, tcam_pos, delta * 5.0)
	cam_pos = lerp(cam_pos, tcam_pos, delta * 5.0)
	if is_on_floor() and slide < 0.1:
		if cam_pos.y >= 0.12 and !right_played:
			play_random_sound(speed_clamped)
			left_played = false
			right_played = true
		if cam_pos.y <= -0.12 and !left_played:
			play_random_sound(speed_clamped)
			left_played = true
			right_played = false
	if slide < 0.1:
		if was_on_floor and !is_on_floor():
			play_random_sound(speed_clamped, jump_sounds)
		if is_on_floor() and !was_on_floor:
			play_random_sound(speed_clamped, land_sounds)
	was_on_floor = is_on_floor()

func play_random_sound(forwardmove : float, sounds : Array = feet_sounds) -> void:
	var current = sounds[0]
	feet.stream = current
	feet.play()
	feet.volume_db = linear_to_db(0.3)
	sounds.shuffle()
	sounds.erase(current)
	sounds.push_back(current)

func WalkMove(delta):
	var forward = Vector3.FORWARD
	var side = Vector3.LEFT
	
	forward = forward.rotated(Vector3.UP, camera.rotation.y)
	side = side.rotated(Vector3.UP, camera.rotation.y)
	
	forward = forward.normalized()
	side = side.normalized()
	
	snap = -get_floor_normal()
	
	var fmove = forwardmove
	var smove = sidemove
	
	var wishvel = side * smove + forward * fmove
	
	Friction(delta)
		
	# Zero out y value
	wishvel.y = 0
	
	var wishdir = wishvel.normalized()
	# VectorNormalize in the original source code doesn't actually return the length of the normalized vector
	# It returns the length of the vector before it was normalized
	var wishspeed = wishvel.length()
	
	# clamp to game defined max speed
	if wishspeed != 0.0 and wishspeed > ply_maxspeed:
		wishvel *= ply_maxspeed / wishspeed
		wishspeed = ply_maxspeed
	
	Accelerate(wishdir, wishspeed, target.ply_accelerate, delta)
	
	$Top.set_disabled(false)
	$Bottom.set_disabled(false)
	
func AirMove(delta):
	
	var forward = Vector3.FORWARD
	var side = Vector3.LEFT
	
	forward = forward.rotated(Vector3.UP, camera.rotation.y)
	side = side.rotated(Vector3.UP, camera.rotation.y)
	
	forward = forward.normalized()
	side = side.normalized()
	
	var fmove = forwardmove
	var smove = sidemove
	
	snap = Vector3.ZERO
	vel.y -= ply_gravity * delta
	
	var wishvel = side * smove + forward * fmove
	
	# Zero out y value
	wishvel.y = 0
	
	var wishdir = wishvel.normalized()
	# VectorNormalize in the original source code doesn't actually return the length of the normalized vector
	# It returns the length of the vector before it was normalized
	var wishspeed = wishvel.length()
	
	# clamp to game defined max speed
	if wishspeed != 0.0 and wishspeed > ply_maxspeed:
		wishvel *= ply_maxspeed / wishspeed
		wishspeed = ply_maxspeed
	
	AirAccelerate(wishdir, wishspeed, ply_airaccelerate, delta)
	
	$Top.set_disabled(false)
	$Bottom.set_disabled(false)
	
func NoclipMove(delta):
	var forward = Vector3.FORWARD
	var side = Vector3.LEFT
	var up = Vector3.UP
	
	forward = forward.rotated(Vector3.UP, camera.rotation.y)
	side = side.rotated(Vector3.UP, camera.rotation.y)
	
	forward = forward.normalized()
	side = side.normalized()
	
	var fmove = forwardmove
	var smove = sidemove
	var umove = xlook
	
	var wishvel = side * smove + forward * fmove
	if fmove != 0:
		wishvel.y += camera.rotation_degrees.x * 50
	
	var wishdir = wishvel.normalized()
	# VectorNormalize in the original source code doesn't actually return the length of the normalized vector
	# It returns the length of the vector before it was normalized
	var wishspeed = wishvel.length()
	
	# clamp to game defined max speed
	if wishspeed != 0.0 and wishspeed > ply_maxspeed:
		wishvel *= ply_maxspeed / wishspeed
		wishspeed = ply_maxspeed
		
	Friction(delta)
	
	Accelerate(wishdir, wishspeed, ply_maxacceleration, delta)

	$top.set_disabled(true)
	$bottom.set_disabled(true)
	
func Accelerate(wishdir, wishspeed, ply_accelerate, delta):
	# See if we are changing direction a bit
	var currentspeed = vel.dot(wishdir)
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
		vel += accelspeed * wishdir
	
func AirAccelerate(wishdir, wishspeed, accel, delta):
	# cap speed
	wishspeed = min(wishspeed, ply_airspeedcap)
	# See if we are changing direction a bit
	var currentspeed = vel.dot(wishdir)
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
		vel += accelspeed * wishdir
	
func Friction(delta):
	# If we are in water jump cycle, don't apply friction
	#if (player->m_flWaterJumpTime)
	#	return

	# Calculate speed
	var speed = vel.length()
	
	# If too slow, return
	if speed < 0:
		return

	var drop = 0

	# apply ground friction
	var friction = ply_friction

	# Bleed unchecked some speed, but if we have less than the bleed
	#  threshold, bleed the threshold amount.
	var control = ply_stopspeed if speed < ply_stopspeed else speed
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
		vel *= newspeed

func CheckJumpButton():
	snap = Vector3.ZERO
			
	if not is_on_floor():
			return
	
	#Events.emit_signal("player_jump")
	var flGroundFactor = 1.0
	var flMul = sqrt(2 * ply_gravity * ply_jumpheight)
	vel.y += flGroundFactor * flMul  # 2 * gravity * height
	
	# Add a little forward velocity based checked your current forward velocity - if you are not sprinting.
	var vel2d = Vector2(vel.x, vel.z)
	var vecforward = Vector3.FORWARD
	vecforward = vecforward.rotated(Vector3.UP, camera.rotation.y)
	vecforward.y = 0
	vecforward = vecforward.normalized()
	# We give a certain percentage of the current forward movement as a bonus to the jump speed.  That bonus is clipped
	# to not accumulate over time.
	var flSpeedBoostPerc = 1.5
	var flSpeedAddition = abs(forwardmove * flSpeedBoostPerc)
	var flMaxSpeed = ply_maxspeed * flSpeedBoostPerc
	var flNewSpeed = flSpeedAddition + vel2d.length()

	# If we're over the maximum, we want to only boost as much as will get us to the goal speed
	if flNewSpeed > flMaxSpeed:
		flSpeedAddition -= flNewSpeed - flMaxSpeed

	if forwardmove < 0:
		flSpeedAddition *= -1.0

	# Add it checked
	vel += vecforward * flSpeedAddition
