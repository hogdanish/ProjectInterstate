@tool
extends State

func _on_update(_delta) -> void:
	if !IsMoving():
		change_state("Idle")

func IsMoving():
	return (target.vel.length() > 0)
