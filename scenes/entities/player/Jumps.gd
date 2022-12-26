@tool
extends State

# FUNCTIONS AVAILABLE TO INHERIT

func _on_enter(_args) -> void:
	var _st = change_state("NoJump")
