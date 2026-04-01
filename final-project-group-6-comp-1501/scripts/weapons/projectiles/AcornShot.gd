extends projectile

func _ready() -> void:
	self.attack.damagesNPC = true
	self.attack.damage = self.damage
	self.attack.pierces = false
	super()
