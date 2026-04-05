extends projectile

func _ready() -> void:
	self.attack.damagesNPC = false
	self.attack.damagesPlayer = true
	self.attack.damage = self.damage
	self.attack.pierces = false
	super()
