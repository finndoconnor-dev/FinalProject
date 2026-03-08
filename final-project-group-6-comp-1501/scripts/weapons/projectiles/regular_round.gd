extends projectile


func onHit(body : Node2D) -> void:
	attack.damage = damage
	attack.damagesPlayer = false
	if body.has_method("onDamage"):
		body.onDamage(attack)
