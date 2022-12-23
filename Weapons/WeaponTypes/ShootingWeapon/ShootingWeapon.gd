extends "res://Assets/Weapons/WeaponTypes/Generic/Weapon.gd"

# barrel components control shooting precision and spread
@onready var barrel = $Barrels/Barrel1

# slides control shot timing and action (semi-auto, auto)
@onready var slide = $Slides/Slide1

# magazines hold ammo; weapons can have more than one
# for differetne ammo types (like an SMG with a granade launcher)
@onready var magazine = $Magazines/Magazine1


func try_shoot() -> void:
	if is_empty(): # automatically reload when trying to shoot while empty
		reload_press()
		return

	var can_shoot = barrel.shoot()
	if can_shoot:
		shoot()


func shoot() -> void:
	# This will be implemented in child classes
	printerr("Shooting is only implemented in child classes")


# checking if the weapon has ammo available
# currently this assumes a single magazine is presents
func is_empty() -> bool:
	return magazine.is_empty()


# overloading parent class method stub
@rpc(call_remote, any_peer, reliable)
func reload_press():
	print("Reloading...")
	if is_empty():
		magazine.reload()
		control_reload = false
