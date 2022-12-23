extends "res://Assets/Weapons/WeaponTypes/ShootingWeapon/ShootingWeapon.gd"

@export var damage_amount : int = 25

@export var full_auto := false

@onready var anim : AnimationPlayer = $AnimationPlayer

@onready var hit_effect : PackedScene = load("res://Assets/Effects/CharacterHitEffect.tscn")

@onready var bullet_tracer : PackedScene = load("res://Assets/Effects/BulletTracer.tscn")

@onready var flyby_sound : PackedScene = load("res://Assets/Audio/BulletFlyBySoundPlayer.tscn")

@onready var damage_label : PackedScene = load("res://Assets/Weapons/Damage/DamageLabel.tscn")

@onready var damage_class = load("res://Assets/Weapons/Damage/DamageShot.gd")

	
var primary_trigger_held := false

func deal_damage(hit):
	var damage = damage_class.new()

	damage.attacker = character
	damage.source_position = $Barrels/Barrel1/ProjectileSpawner.to_global(Vector3(0.0, 0.0, 0.0))
	damage.hit_position = hit.position
	damage.damage_amount = damage_amount
	
	hit.collider.hurt(damage)

	spawn_hit_effect(hit, hit.collider.state.team)

func spawn_hit_effect(hit, team: int):
	var effect = hit_effect.instantiate()
	effect.team = team
	get_tree().root.add_child(effect)
	effect.global_position = hit.position
	if -0.95 < hit.normal.dot(Vector3.UP) and\
		0.95 > hit.normal.dot(Vector3.UP):
		effect.look_at(hit.position + hit.normal)
	else:
		effect.look_at(hit.position + hit.normal, Vector3.FORWARD)
	effect.trigger()

func spawn_damage_label(hit):
	var label = damage_label.instantiate()

	var factor = 1 if hit.collider.state.team != character.state.team else MultiplayerState.game_config.friendy_fire_amount

	label.damage_amount = damage_amount * factor
	label.global_position = hit.position
	get_tree().root.add_child(label)

func spawn_bullet_tracer(target):
	var tracer = bullet_tracer.instantiate()
	get_tree().root.add_child(tracer)
	tracer.global_transform = global_transform
	tracer.look_at(target)
	print("Bullet tracer spawned: ", tracer, " on peer ", multiplayer.get_unique_id(), " on behalf of ", multiplayer.get_remote_sender_id())

func spawn_bullet_flyby_sound(target):
	if Globals.current_character:
		var flyby_camera = get_tree().get_root().get_camera_3d()

		# TODO
		# if flyby_camera == camera: # don't spawn flyby sound for the shooter
		# 	return

		var x := Vector3.ZERO
		var A = global_position
		var B = target
		var C = flyby_camera.global_transform.origin

		var d0 = (B - A).dot(A - C)
		var d1 = (B - A).dot(B - C)

		if d0 < 0 and d1 < 0:
			print("Firing away from the camera")
		elif d0 > 0 and d1 > 0:
			print("Bullet hit before passing by")
		else:
			var X = d0/(d0-d1)
			var flyby = flyby_sound.instantiate()
			get_tree().root.add_child(flyby)
			flyby.global_transform.origin = A + X * (B - A)

# reset after respawn
func reset() -> void:
	for m in $Magazines.get_children():
		m.reset()


func shoot():
	# ensure we're not currently reloading
	if magazine.is_reloading:
		return

	# ensure we're not empty - of we are, reload instead
	if is_empty():
		reload_press()
		if multiplayer.has_multiplayer_peer():
			reload_press.rpc()
		return

	# ensure the gun is ready to shoot (slide returned etc)
	if not $Barrels/Barrel1.can_shoot():
		return

	# shoot
	var hits : Array = $Barrels/Barrel1.shoot().hits
	var target : Vector3 = $Barrels/Barrel1.shoot().targets[0]

	# play the shoot animation
	if anim.is_playing():
		anim.stop()
	anim.play("Shoot")

	# now process what did we hit (if anything)
	if not hits.is_empty():
		for hit in hits:
			if hit.collider is Character:
				# only the authority processes the logic here, non-authorities only execute an RPC
#				if MultiplayerState.role != Globals.MultiplayerRole.NONE:
#					if character.is_multiplayer_authority():
				deal_damage(hit)
			else:
				# this is done on all peers indepndently because it's not crucial to get synced right
				spawn_hit_effect(hit, 0)

	spawn_bullet_tracer(target)

	if str(multiplayer.get_remote_sender_id()) == character.name:
		spawn_bullet_flyby_sound(target)

	if full_auto and primary_trigger_held and character.state.alive:
		await $Slides/Slide1.slide_returned
		shoot()

func trigger_primary_press():
#	print("Trigger primary press")
	primary_trigger_held = true
	shoot()


func trigger_primary_release():
#	print("Trigger primary release")
	primary_trigger_held = false

func reload_press():
#	print("Reload pressed")
	if magazine.is_reloading:
		return

	if anim.is_playing():
		return

	for m in $Magazines.get_children():
		m.reload()

		if anim.is_playing():
			anim.stop()
		anim.play("Reload")
