extends Node2D
class_name gun

@export var projectileScene : PackedScene
@export var useSpeed : float = 0 #how many seconds you must wait before using the weapon again
@export var maxAmmoCount : int = 0 #The amount of ammo the player has
@export var attachedToPlayer=true

@onready var gunRotate : Node2D = $GunRotate #Sprite and rotation controller
@onready var projPoint : Marker2D = $GunRotate/ExitPoint #The muzzle of the gun's sprite, where the bullet will spawn.
@onready var cooldownTimer : Timer = $UseCooldown #Timer for cooldown.

signal gunFired

var ammoCount : int = maxAmmoCount


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ammoCount = maxAmmoCount
	cooldownTimer.one_shot = true #Makes it so that the timer will not restart when time reaches 0
	pass # Replace with function body.

#This is being stolen for the nemies when the enmies get guns they shoot every frame from the same weapon pool
func _process(delta: float) -> void:
	pass
		
	
func isEmpty() -> bool:
	return ammoCount <= 0
	
func reload() -> void:
	ammoCount = maxAmmoCount	
	
func tryShoot() -> void:
	#print("Attempting to shoot " + self.name)
	#Check to see if there is a linked scene in the godot GUI.
	if projectileScene == null:
		print(self.name + " has no attached projectile scene")
		return
	#Check to see if the gun is on cooldown.
	if !cooldownTimer.is_stopped():
		#print(self.name + " is on cooldown.")
		return
	#Check if the gun has ammo
	if isEmpty():
		return
	#Finally create the projectile.
	cooldownTimer.start(useSpeed)
	ammoCount -= 1
	gunFired.emit()
	createProjectile()
	
func createProjectile() -> void:
	print("Gun of name "+self.name+" has no overridden createProjectile() method.")
