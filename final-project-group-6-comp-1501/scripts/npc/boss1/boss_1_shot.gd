extends projectile

func onHit(body:Node2D) -> void:
	attack.damage = damage
	attack.damagesPlayer = true
	attack.damagesNPC = false
	if body.has_method("onDamage"):
		if body.onDamage(attack):
			queue_free()
