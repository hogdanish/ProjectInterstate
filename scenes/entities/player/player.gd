extends CharacterBody3D
class_name Player

@onready var player : CharacterBody3D = self
@onready var top: CollisionShape3D = $Top
@onready var bottom: CollisionShape3D = $Bottom
@onready var camera: Camera3D = $Camera
@export var default_fov: float

@export var fov_multiplier := 1.12
@onready var normal_fov: float = camera.fov

# Movement sounds
@onready var feet_sounds = [
	preload("res://assets/audio/player/steps/concrete_01.ogg"),
	preload("res://assets/audio/player/steps/concrete_02.ogg"),
	preload("res://assets/audio/player/steps/concrete_03.ogg"),
	preload("res://assets/audio/player/steps/concrete_04.ogg"),
	preload("res://assets/audio/player/steps/concrete_05.ogg"),
	preload("res://assets/audio/player/steps/concrete_06.ogg")
]
@onready var land_sounds = [
	preload("res://assets/audio/player/steps/land_concrete_01.ogg"),
	preload("res://assets/audio/player/steps/land_concrete_02.ogg"),
	preload("res://assets/audio/player/steps/land_concrete_03.ogg"),
	preload("res://assets/audio/player/steps/land_concrete_04.ogg"),
	preload("res://assets/audio/player/steps/land_concrete_05.ogg")
]
@onready var jump_sounds = [
	preload("res://assets/audio/player/steps/jump_concrete_01.ogg"),
	preload("res://assets/audio/player/steps/jump_concrete_03.ogg")
]

var left_played : bool = false
var right_played : bool = false
var was_on_floor : bool = false

# Object interaction
var coll
var coll_buffer = null
var held_object : Object
var image
var phys_props
var pull_power = 10
var rotation_power = 0.1
var locked = false

# Throwing modulation
var strength := 0.0
@export_range(2.0, 10.0) var strength_speed: float = 45.0*14
@export_range(5.0, 20.0) var max_strength: float = 50.0*14

# Bools
var stopfuckingcrouchinginmidairyoufuckingcunt : bool = false
var bob_enabled : bool = false
var rotating : bool
var grabbing : bool
var charging : bool
var has_been_capped : bool = false
var noclip : bool
var crouching : bool
var crouched : bool
var sprinting : bool

# Floats
const ply_cambob : float = 0.33
var sidemove : float
var upmove : float
var forwardmove : float
var ylook : float
var xlook : float
var t : float = 0.0

# Vectors
var vel = Vector3.ZERO
var snap = Vector3.DOWN
var cam_pos : Vector2
var translation

# ConVars
var ply_mousesensitivity = 2
var ply_maxlookangle_down = -90
var ply_maxlookangle_up = 90
var ply_ylookspeed = 0.3
var ply_xlookspeed = 0.3
var ply_sidespeed = 20
var ply_upspeed = 20
var ply_forwardspeed = 20
var ply_backspeed = 20
var ply_maxacceleration = 5000 # Not sure waht this does
var ply_maxvelocity = 35000 #35000, doesn't seem to do much atm
var ply_accelerate = 10 # acceleration when pressing direction
var ply_airaccelerate = 3
var ply_airspeedcap = 15
var ply_friction = 4
var ply_stopspeed : float = 100 # 100, how slidey character is 
var ply_gravity = 120
var ply_maxslopeangle = deg_to_rad(45)
var ply_crouchstanceheight = 2
var ply_crouchedheight = -1
var ply_crouchlerpweight = 0.4
var ply_jumpheight = 6
var ply_maxspeed = 32 # Seems to affect jumping only
var ply_stepspeed

#Movement speed controls
var ply_sprint_speed : float = 32
var ply_sprint_step_speed = 25
var ply_walk_speed : float = 20
var ply_walk_step_speed = 15
var ply_crouchsprint_speed : float = 20
var ply_crouchsprint_step_speed = 15
var ply_crouch_speed : float = 15
var ply_crouch_step_speed = 7

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Globals.player = self
	#vel = Vector3.ZERO
	#health = max_health

func _process(delta: float) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		ViewAngles(delta)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			InputMouse(event)

func InputMouse(event):
	xlook += -event.relative.y * ply_xlookspeed 
	ylook += -event.relative.x * ply_ylookspeed
	xlook = clamp(xlook, ply_maxlookangle_down, ply_maxlookangle_up)

func ViewAngles(_delta):
	camera.rotation.x = deg_to_rad(xlook)
	camera.rotation.y = deg_to_rad(ylook)
	
#func _physics_process(delta: float) -> void:
#	if is_on_floor() and noclip == false:
#		WalkMove(delta)
#	else:
#		AirMove(delta)
#	set_velocity(vel)
#	set_up_direction(Vector3.UP)
#	set_floor_stop_on_slope_enabled(true)
#	set_max_slides(4)
#	set_floor_max_angle(ply_maxslopeangle)
#	move_and_slide()
#	vel = velocity

#func WalkMove(delta):
#	var forward = Vector3.FORWARD
#	var side = Vector3.LEFT
#
#	forward = forward.rotated(Vector3.UP, camera.rotation.y)
#	side = side.rotated(Vector3.UP, camera.rotation.y)
#
#	forward = forward.normalized()
#	side = side.normalized()
#
#	snap = -get_floor_normal()
#
#	var fmove = forwardmove
#	var smove = sidemove
#
#	var wishvel = side * smove + forward * fmove
#
#	Friction(delta)
#
#	# Zero out y value
#	wishvel.y = 0
#
#	var wishdir = wishvel.normalized()
#	# VectorNormalize in the original source code doesn't actually return the length of the normalized vector
#	# It returns the length of the vector before it was normalized
#	var wishspeed = wishvel.length()
#
#	# clamp to game defined max speed
#	if wishspeed != 0.0 and wishspeed > ply_maxspeed:
#		wishvel *= ply_maxspeed / wishspeed
#		wishspeed = ply_maxspeed
#
#	Accelerate(wishdir, wishspeed, ply_accelerate, delta)
#
#	$Top.set_disabled(false)
#	$Bottom.set_disabled(false)
#
#func AirMove(delta):
#
#	var forward = Vector3.FORWARD
#	var side = Vector3.LEFT
#
#	forward = forward.rotated(Vector3.UP, camera.rotation.y)
#	side = side.rotated(Vector3.UP, camera.rotation.y)
#
#	forward = forward.normalized()
#	side = side.normalized()
#
#	var fmove = forwardmove
#	var smove = sidemove
#
#	snap = Vector3.ZERO
#	vel.y -= ply_gravity * delta
#
#	var wishvel = side * smove + forward * fmove
#
#	# Zero out y value
#	wishvel.y = 0
#
#	var wishdir = wishvel.normalized()
#	# VectorNormalize in the original source code doesn't actually return the length of the normalized vector
#	# It returns the length of the vector before it was normalized
#	var wishspeed = wishvel.length()
#
#	# clamp to game defined max speed
#	if wishspeed != 0.0 and wishspeed > ply_maxspeed:
#		wishvel *= ply_maxspeed / wishspeed
#		wishspeed = ply_maxspeed
#
#	AirAccelerate(wishdir, wishspeed, ply_airaccelerate, delta)
#
#	$Top.set_disabled(false)
#	$Bottom.set_disabled(false)
#
#func Accelerate(wishdir, wishspeed, accel, delta):
#	# See if we are changing direction a bit
#	var currentspeed = vel.dot(wishdir)
#	# Reduce wishspeed by the amount of veer.
#	var addspeed = wishspeed - currentspeed
#
#	# If not going to add any speed, done.
#	if addspeed <= 0:
#		return
#
#	# Determine amount of accleration.
#	var accelspeed = accel * wishspeed * delta
#
#	# Cap at addspeed
#	accelspeed = min(accelspeed, addspeed)
#
#	for i in range(3):
#		# Adjust velocity.
#		vel += accelspeed * wishdir
#
#func AirAccelerate(wishdir, wishspeed, accel, delta):
#	# cap speed
#	wishspeed = min(wishspeed, ply_airspeedcap)
#	# See if we are changing direction a bit
#	var currentspeed = vel.dot(wishdir)
#	# Reduce wishspeed by the amount of veer.
#	var addspeed = wishspeed - currentspeed
#
#	# If not going to add any speed, done.
#	if addspeed <= 0:
#		return
#
#	# Determine amount of accleration.
#	var accelspeed = accel * wishspeed * delta 
#
#	# Cap at addspeed
#	accelspeed = min(accelspeed, addspeed)
#
#	for i in range(3):
#		# Adjust velocity.
#		vel += accelspeed * wishdir
#
#func Friction(delta):
#	# If we are in water jump cycle, don't apply friction
#	#if (player->m_flWaterJumpTime)
#	#	return
#
#	# Calculate speed
#	var speed = vel.length()
#
#	# If too slow, return
#	if speed < 0:
#		return
#
#	var drop = 0
#
#	# apply ground friction
#	var friction = ply_friction
#
#	# Bleed unchecked some speed, but if we have less than the bleed
#	#  threshold, bleed the threshold amount.
#	var control = ply_stopspeed if speed < ply_stopspeed else speed
#	# Add the amount to the drop amount.
#	drop += control * friction * delta
#
#	# scale the velocity
#	var newspeed = speed - drop
#	if newspeed < 0:
#		newspeed = 0
#
#	if newspeed != speed:
#		# Determine proportion of old speed we are using.
#		newspeed /= speed
#		# Adjust velocity according to proportion.
#		vel *= newspeed

#func _unhandled_input(event: InputEvent) -> void:
#	state.input(event)

#func _physics_process(delta: float) -> void:
#	state.physics_process(delta)

## Health and Damage	
#func _player_hud_update(update: PlayerHudUpdate) -> void:
#	update.player = self
#	#player_hud_update.emit(update)
#
#func hurt(_damage) -> void:
#
#	var damage : Damage
#	if _damage is Damage:
#		damage = _damage
#	elif _damage is Dictionary:
#		damage = dict_to_inst(_damage)
#
#	#health -= damage.damage_amount
#	#$Audio/Hurt.play()
#
#	#if health <= 0:
#	#	die()
#
#	var update = PlayerHudUpdate.new()
#	update.player = self
#	update.got_damage = damage
#	#player_hud_update.emit(update)
#
#func die() -> void:
#	#if alive == false:
#		#return
#
#	#play death sound
#
#	var update = PlayerHudUpdate.new()
#	update.player = self
#	update.got_killed = true
#
#	var damage = DamageFall
#
#	update.got_damage = damage
#	#health = 0
#	#player_hud_update.emit(update)
#
#	#var tween = create_tween()
#	#tween.tween_property(self, "rotation", rotation + Vector3(PI/ 2,0,0), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
#	#tween.parallel()
#	#tween.tween_property(self, "position", self.position - Vector3(0,0.3,0), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
#	#tween.play()
#
#	#if health > 0:
#	#	health = 0
#
#	#alive = false
#
#	var spawn_transform = Globals.game.get_spawn_transform()
#
#	Globals.emit_signal("player_dead")
	
	
	
