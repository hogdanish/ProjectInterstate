@tool
extends State

@export var speed_boost : float = 1.5
#@export var air_accel_boost : float = 1.0
@export var friction_boost : float = 2.0
@export var fov_boost : float = 1.12
@export_exp_easing var lerp_weight : float = 16.0

var delta_value : float
var tw : Tween

func _on_enter(_args) -> void:
	delta_value = speed_boost * target.ply_maxspeed

func _on_update(_delta) -> void:
	target.camera.set_fov(lerp(target.camera.fov, target.normal_fov * fov_boost, _delta * lerp_weight))
	target.ply_maxspeed = lerp(target.ply_maxspeed, delta_value, _delta * lerp_weight)
	
	if Input.is_action_just_released("sprint"):
		change_state("Moving")
