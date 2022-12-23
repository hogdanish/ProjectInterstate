extends PlayerMovement
class_name Player

func _ready():
	Globals.player = self
	health = max_health

# Health and Damage
	
func _player_hud_update(update: PlayerHudUpdate) -> void:
	update.player = self
	player_hud_update.emit(update)

func hurt(_damage) -> void:

	var damage : Damage
	if _damage is Damage:
		damage = _damage
	elif _damage is Dictionary:
		damage = dict_to_inst(_damage)
	
	health -= damage.damage_amount
	$audio/Hurt.play()
	
	if health <= 0:
		die()

	var update = PlayerHudUpdate.new()
	update.player = self
	update.got_damage = damage
	player_hud_update.emit(update)

func die() -> void:
	if alive == false:
		return

	#play death sound
	
	var update = PlayerHudUpdate.new()
	update.player = self
	update.got_killed = true
	
	var damage = DamageFall
	
	update.got_damage = damage
	health = 0
	player_hud_update.emit(update)
	
	var tween = create_tween()
	tween.tween_property(self, "rotation", rotation + Vector3(PI/ 2,0,0), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.parallel()
	tween.tween_property(self, "position", self.position - Vector3(0,0.3,0), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.play()
	
	if health > 0:
		health = 0
	
	alive = false
	
	var spawn_transform = game_state.get_spawn_transform()
	
	Globals.emit_signal("player_dead")
	
	
	
