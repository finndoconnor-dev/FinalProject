extends penguin

@export var cube : PackedScene
@export var throwCooldown : float = 0.4
@export var numberOfCubes : int = 5
var hasIce = true

func _ready() -> void:
	super()
	self.speed = 30
	animatedSprite.play("hascube")

func _physics_process(delta: float) -> void:
	super(delta)
	if numberOfCubes <= 0:
		changeForm()

func onDamageTimer() -> void:
	if !hasIce:
		attackInRadius()

func onThrowRadiusEntered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Throwing Cube")
		throwCube()


func throwCube():
	if (numberOfCubes > 0):
		numberOfCubes-=1
		var proj = cube.instantiate()
		get_tree().current_scene.add_child(proj)
		proj.global_transform = self.global_transform
		proj.look_at(getPlayer().global_position)
		self.speed = 0
		await get_tree().create_timer(throwCooldown).timeout
		self.speed = 30

func changeForm():
	animatedSprite.play("default")
	hasIce = false
	self.speed = 75
