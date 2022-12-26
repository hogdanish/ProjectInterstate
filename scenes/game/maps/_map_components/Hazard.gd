extends Area3D

@export var trauma_amount := 0.1
@export var damage_amount := 25

func _on_hazard_body_entered(body):
	if body is Player:
		var damage = DamagePunch.new()
		damage.damage_amount = damage_amount
		damage.trauma_amount = trauma_amount
		
		#body.hurt(damage) 
		#body.camera.add_trauma(trauma_amount)
