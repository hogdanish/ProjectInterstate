extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	Events.player_jump.connect(_on_jump)
#	Events.player_charge.connect(_on_charge)
#	Events.player_grab.connect(_on_grab)
#	Events.player_drop.connect(_on_drop)
#	Events.player_release.connect(_on_release)
#	Events.player_charge_cap.connect(_on_player_charge_cap)
#	Events.player_throw.connect(_on_player_throw)










func _on_jump():
	$Jump.play()

func _on_charge():
	$Charge.play()

func _on_grab():
	$Grab.play()

func _on_drop():
	$Drop.play()
	$Capped.stop()

func _on_release():
	$Release.play()
	$Capped.stop()

func _on_player_charge_cap():
	$Capped.play()

func _on_player_throw():
	$Capped.stop()
