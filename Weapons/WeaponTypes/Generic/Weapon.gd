extends Node3D
class_name Weapon

var controls = {
	Globals.PlayerControlType.TRIG_P : PlayerControl.new(),
	Globals.PlayerControlType.TRIG_S : PlayerControl.new(),
	Globals.PlayerControlType.WEPN_R : PlayerControl.new(),
	}

var trigger_primary: bool = false:
	get:
		return trigger_primary
	set(value):
		if trigger_primary != value:
			trigger_primary = value
			if value:
				trigger_primary_press()
			else:
				trigger_primary_release()

var trigger_secondary: bool = false:
	get:
		return trigger_secondary
	set(value):
		if trigger_secondary != value:
			trigger_secondary = value
			if value:
				trigger_secondary_press()
			else:
				trigger_secondary_release()

var control_reload: bool = false:
	get:
		return control_reload
	set(value):
		if control_reload != value:
			control_reload = value
			if value:
				reload_press()
			else:
				reload_release()

func trigger_primary_press():
	pass #print("Primary trigger press")

func trigger_primary_release():
	pass #print("Primary trigger release")

func trigger_secondary_press():
	pass #print("Secondary trigger press")

func trigger_secondary_release():
	pass #print("Secondary trigger release")

func reload_press():
	pass #print("Reload press")

func reload_release():
	pass #print("Reload release")

func deal_damage(target):
	pass

# stub to be overloaded by subclasses
func process(delta):
	pass

# reset the weapon state - usually after a repawn
func reset():
	print("The reset method must be overloaded on descendant classes")

func _ready() -> void:
	# controls are missing control_type
	for ctrl in controls.keys():
		var type = ctrl
		controls[type].control_type = type


#func _controller_event(event: CharCtrlEvent) -> void:
#	# apply control changes to locally tracked events
#	for cc in event.control_changes:
#		if cc.control_type in controls.keys():
#			controls[cc.control_type].enabled = cc.enabled
#
#	#primary trigger
#	if controls[Globals.CharCtrlType.TRIG_P].changed: # changed gets reset to false whenever we check it
#		trigger_primary = controls[Globals.CharCtrlType.TRIG_P].enabled
#
#	# secondary trigger
#	if controls[Globals.CharCtrlType.TRIG_S].changed: # changed gets reset to false whenever we check it
#		trigger_secondary = controls[Globals.CharCtrlType.TRIG_S].enabled
#
#	# reloading
#	if controls[Globals.CharCtrlType.WEPN_R].changed:
##		print("Activating reload")
#		control_reload = controls[Globals.CharCtrlType.WEPN_R].enabled
