@tool
extends State

var stopfuckingcrouchinginmidairyoufuckingcunt : bool = false

func _on_enter(_args) -> void:
	change_state("Standing")

func _on_update(_delta: float) -> void:
	if target.is_on_floor():
		stopfuckingcrouchinginmidairyoufuckingcunt = false
		
	if !stopfuckingcrouchinginmidairyoufuckingcunt:
		Crouch()
	
	if Input.is_action_pressed("crouch"):
		target.crouching = true
	elif Input.is_action_just_released("crouch"):
		target.crouching = false
	
	if target.crouching:
		target.crouched = true
	if !target.crouching:
		target.crouched = false
	
	if target.is_on_floor() and target.crouched:
		target.camera.position = target.camera.position.lerp(Vector3(0, target.ply_crouchedheight, 0), target.ply_crouchlerpweight)
	if target.is_on_floor() and !target.crouched:
		target.camera.position = target.camera.position.lerp(Vector3(0, target.ply_crouchstanceheight, 0), target.ply_crouchlerpweight)
	if !target.is_on_floor() and target.crouched:
		target.camera.position = target.camera.position.lerp(Vector3(0, target.ply_crouchedheight, 0), target.ply_crouchlerpweight)


func Crouch():
	# dumbest shit i ever coded
	if target.crouching and !target.is_on_floor() and Input.is_action_just_pressed("crouch"):
		var up = target.top.get_translation(); var down = target.bottom.get_translation();
		
		# FUCKING CROUCHJUMPING
		target.global_translate(Vector3(0, up.distance_to(down) / 2.5, 0))
		target.global_translate(Vector3(0, down.distance_to(up) / 2.5, 0))
		
		if !target.is_on_floor():
			stopfuckingcrouchinginmidairyoufuckingcunt = true
