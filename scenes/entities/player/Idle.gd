@tool
extends State

func _on_update(delta) -> void:
	target.camera.set_fov(lerp(target.camera.fov, target.normal_fov, delta * 8))
	target.ply_maxspeed = target.ply_walk_speed
	#target.ply_stepspeed = target.ply_walk_step_speed
	#target.ply_friction = 4
	#target.ply_airaccelerate = 3
	if IsMoving():
		change_state("Moving")

func IsMoving():
	return (target.vel.length() > 0)
