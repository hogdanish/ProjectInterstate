extends Control

var static_visible : bool = true
var debug_visible : bool = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_debug"):
		if debug_visible:
			$Debug.hide()
			debug_visible = false
		else:
			$Debug.show()
			debug_visible = true
	if Input.is_action_just_pressed("in_hide"):
		if static_visible:
			$Stats.hide()
			static_visible = false
		else:
			$Stats.show()
			static_visible = true

var pain: float = 0:
	set(value):
		pain = value
		$Overlays/Damage.color.a = pain
	get:
		return pain

func damage(hp) -> void:
#	print("HUD damage ", hp)
	pain += hp / 20

func _on_player_loaded(player: CharacterBody3D) -> void:
	if player:
		player.player_hud_update.connect(player_hud_update)

func _ready() -> void:
	# hud is invisible by default, only shows when gets a character to follow
	#hide()

	#Globals.current_character_changed.connect(_on_current_character_changed)
	#Globals.focus_changed.connect(_on_focus_changed)
	Globals.player_loaded.connect(_on_player_loaded)

	pain = 0

func _process(delta) -> void:
	if pain > 0:
		pain = lerpf(pain, 0, delta)

func player_hud_update(update: PlayerHudUpdate) -> void:
	if update.got_damage:
		var health_bar = get_node("Stats").get_node("Health")
		health_bar.get_node("HP").text = "HP: " + str(update.player.health).lpad(3, " ") + " / " + str(update.player.max_health).lpad(3, " ")
		#health_bar.value = update.player.health
		#health_bar.max_value = update.player.max_health

		if update.got_damage:
#			print("Adding damage to pain: ", update.got_damage.damage_amount)
			pain += clampf(update.got_damage.damage_amount / 50.0, 0.33, 0.45) * 3
#			print("HUD spawns a damage compass marker")
			#$DamageCompass.add_marker(update.got_damage)
			
			if update.got_killed:
				pain += 1
#	if update.got_killed:
#		$DeathScreen.show()
#		$Stats.hide()
