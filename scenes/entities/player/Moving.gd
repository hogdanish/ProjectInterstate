@tool
extends State

func _on_update(delta) -> void:
	target.camera.set_fov(lerp(target.camera.fov, target.normal_fov, delta * 8))
	target.ply_maxspeed = target.ply_walk_speed

	if Input.is_action_pressed("sprint") and !is_active("Idle"):
		change_state("Sprinting")
