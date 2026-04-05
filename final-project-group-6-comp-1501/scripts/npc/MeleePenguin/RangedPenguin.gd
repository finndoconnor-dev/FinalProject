extends penguin

@export var cube : PackedScene
@export var throwCooldown : float = 0.4
@export var numberOfCubes : int = 5
@export var rangedMoveSpeed : float = 30.0
@export var meleeMoveSpeed : float = 75.0

var hasIce = true
var playerInThrowRadius := false
var throwCooldownRemaining := 0.0

func _ready() -> void:
	super()
	self.speed = rangedMoveSpeed
	animatedSprite.play("hascube")

func _physics_process(delta: float) -> void:
	if throwCooldownRemaining > 0.0:
		throwCooldownRemaining = max(throwCooldownRemaining - delta, 0.0)
		if throwCooldownRemaining == 0.0 and hasIce:
			speed = rangedMoveSpeed

	if hasIce and playerInThrowRadius and throwCooldownRemaining == 0.0 and numberOfCubes > 0:
		throwCube()

	super(delta)
	if hasIce and numberOfCubes <= 0:
		changeForm()

func onDamageTimer() -> void:
	if !hasIce:
		attackInRadius()

func onThrowRadiusEntered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		playerInThrowRadius = true

func onThrowRadiusExited(body: Node2D) -> void:
	if body.is_in_group("player"):
		playerInThrowRadius = false

func throwCube():
	if !hasIce or numberOfCubes <= 0 or cube == null:
		return
	if player == null or !is_instance_valid(player):
		player = getPlayer()
	if player == null:
		return

	numberOfCubes -= 1
	var proj = cube.instantiate()
	var proj2= cube.instantiate()
	var proj3= cube.instantiate()
	get_tree().current_scene.add_child(proj)
	get_tree().current_scene.add_child(proj2)
	get_tree().current_scene.add_child(proj3)

	proj.global_transform = global_transform
	proj2.global_transform = global_transform
	proj3.global_transform = global_transform
	proj.look_at(player.global_position)
	proj2.look_at(player.global_position)
	proj3.look_at(player.global_position)
	proj2.global_rotation_degrees += 45
	proj3.global_rotation_degrees -= 45

	speed = 0
	throwCooldownRemaining = throwCooldown

func changeForm():
	animatedSprite.play("default")
	hasIce = false
	playerInThrowRadius = false
	throwCooldownRemaining = 0.0
	self.speed = meleeMoveSpeed
