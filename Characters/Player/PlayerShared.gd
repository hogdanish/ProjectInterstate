extends CharacterBody3D
class_name PlayerShared

# Definitions and signals
signal health_changed

# Health and death
@export var max_health: int = 100
@onready var dead : bool = false
@onready var alive : bool = true
@onready var health : int

# Anatomy
@onready var player : CharacterBody3D = get_tree().get_root().get_node("/root/Game/player")
@onready var top: CollisionShape3D = get_tree().get_root().get_node("/root/Game/player/top")
@onready var bottom: CollisionShape3D = get_tree().get_root().get_node("/root/Game/player/bottom")
@onready var camera: Camera3D = get_tree().get_root().get_node("/root/Game/player/camera")
@onready var interaction: RayCast3D = get_tree().get_root().get_node("/root/Game/player/camera/interaction")
@onready var hand: Marker3D = get_tree().get_root().get_node("/root/Game/player/camera/hand")
@onready var animplayer: AnimationPlayer = get_tree().get_root().get_node("/root/Game/player/camera/hand/AnimationPlayer")
@onready var joint: Generic6DOFJoint3D = get_tree().get_root().get_node("/root/Game/player/camera/joint")
@onready var staticbody: StaticBody3D = get_tree().get_root().get_node("/root/Game/player/camera/staticbody")
@onready var feet: AudioStreamPlayer = get_tree().get_root().get_node("/root/Game/player/audio/Feet")

# Settings (temp)
@export var fov_multiplier := 1.12
@onready var normal_fov: float = camera.fov

# Movement sounds
@onready var feet_sounds = [
	preload("res://Audio/player/steps/concrete_01.ogg"),
	preload("res://Audio/player/steps/concrete_02.ogg"),
	preload("res://Audio/player/steps/concrete_03.ogg"),
	preload("res://Audio/player/steps/concrete_04.ogg"),
	preload("res://Audio/player/steps/concrete_05.ogg"),
	preload("res://Audio/player/steps/concrete_06.ogg")
]
@onready var land_sounds = [
	preload("res://Audio/player/steps/land_concrete_01.ogg"),
	preload("res://Audio/player/steps/land_concrete_02.ogg"),
	preload("res://Audio/player/steps/land_concrete_03.ogg"),
	preload("res://Audio/player/steps/land_concrete_04.ogg"),
	preload("res://Audio/player/steps/land_concrete_05.ogg")
]
@onready var jump_sounds = [
	preload("res://Audio/player/steps/jump_concrete_01.ogg"),
	preload("res://Audio/player/steps/jump_concrete_03.ogg")
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
var ply_stopspeed = 100 # 100, how slidey character is 
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
