extends penguin

@export var cube : PackedScene
var hasIce = true

func _ready() -> void:
	super()
	self.speed = 30
	animatedSprite.play("hascube")

func onDamageTimer() -> void:
	if !hasIce:
		attackInRadius()

func onThrowRadiusEntered(body: Node2D) -> void:
	if body.is_in_group("player"):
		throwCube()

func throwCube():
	pass
