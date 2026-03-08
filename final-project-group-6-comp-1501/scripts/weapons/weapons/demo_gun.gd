extends Node2D

@export var projectileScene : PackedScene
@export var useSpeed = 0.5 #how many seconds you must wait before using the weapon again
@export var ammoCount=30 #The amount of ammo the player has
@export var attachedToPlayer=true

@onready var gunRotate : Node2D = $GunRoatate #Sprite and rotation controller
@onready var projPoint : Marker2D = $GunRoatate/ExitPoint #The muzzle of the gun's sprite, where the bullet will spawn.
@onready var cooldownTimer : Timer = $UseCooldown #Timer for cooldown.
signal gunFired



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cooldownTimer.one_shot = true #Makes it so that the timer will not restart when time reaches 0
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if 	attachedToPlayer:
		if Input.is_action_pressed("left_click"):
			tryShoot()
	else:
		tryShoot()
		
func tryShoot() -> void:
	#Check to see if there is a linked scene in the godot GUI.
	if projectileScene == null:
		print(self.name + " has no attached projectile scene")
		return
	#Check to see if the gun is on cooldown.
	if !cooldownTimer.is_stopped():
		#print(self.name + " is on cooldown.")
		return
	cooldownTimer.start(useSpeed)
	createProjectile()
	
func createProjectile() -> void:
	gunFired.emit()
	var proj = projectileScene.instantiate()
	get_tree().root.add_child(proj)
	proj.global_position = projPoint.global_position
	proj.global_rotation_degrees = projPoint.global_rotation_degrees
	
	
