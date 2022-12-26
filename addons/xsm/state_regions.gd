@tool
extends State
class_name StateRegions
@icon("res://addons/xsm/icons/state_regions.png")

# StateRegions has all its children active or inactive at the same time

#
# PRIVATE FUNCTIONS
#

# overridden to have all children ACTIVE
func _init_status_active() -> void:
	enter()
	for c in get_children():
		if c is State:
			c._init_status_active()
	_after_enter(null)


func change_children_status_to_exiting() -> void:
	for c in get_children():
		c.status = EXITING
		c.change_children_status_to_exiting()


func change_children_status_to_entering(new_state_path: NodePath) -> void:
	for c in get_children():
		c.status = ENTERING
		c.change_children_status_to_entering(new_state_path)


func enter_children(args_on_enter = null, args_after_enter = null) -> void:
	if disabled:
		return
	# if hasregions, enter all children and that's all
	for c in get_children():
		c.enter(args_on_enter)
		c.enter_children(args_on_enter, args_after_enter)
		c._after_enter(args_after_enter)


# returns all children if active
func get_active_substate():
	if status == ACTIVE:
		return get_children()
	return null
