extends Node2D
class_name gun

@export var projectileScene : PackedScene
@export var useSpeed : float = 0 #how many seconds you must wait before using the weapon again
@export var maxAmmoCount : int = 0 #The amount of ammo the player has
@export var reloadSpeed : float = 0 #The amount of time a gun takes to re-enter the queue.
@export var attachedToPlayer=true
@export var displayName : String #name displayed on UI elements.
#upgrade variables
@export var speedUpgradeRange: Array = [0.0,0.0]
@export var ammoUpgradeRange: Array = [0,0]
@export var cooldownUpgradeRange: Array = [0.0,0.0]


@onready var gunRotate : Node2D = $GunRotate #Sprite and rotation controller
@onready var projPoint : Marker2D = $GunRotate/ExitPoint #The muzzle of the gun's sprite, where the bullet will spawn.
@onready var cooldownTimer : Timer = $UseCooldown #Timer for cooldown.
@onready var queueCooldown : Timer = Timer.new()

signal gunFired
signal addToQueue(gun)

var ammoCount : int = maxAmmoCount


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ammoCount = maxAmmoCount
	cooldownTimer.one_shot = true #Makes it so that the timer will not restart when time reaches 0
	queueCooldown.one_shot = true
	queueCooldown.timeout.connect(offCooldown)
	add_child(queueCooldown)
	queueCooldown.start(reloadSpeed)

#This is being stolen for the nemies when the enmies get guns they shoot every frame from the same weapon pool
func _process(delta: float) -> void:
	pass
	
func isEmpty() -> bool:
	return ammoCount <= 0
#shooting methods ----------------------------------------------------
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
#Cooldown methods --------------------------------------------------
func onCooldown() -> void:
	ammoCount = maxAmmoCount
	queueCooldown.start(reloadSpeed)

func offCooldown() -> void:
	print(displayName + " is off cooldown.")
	addToQueue.emit(self)
#Upgrade methods ---------------------------------------------------	
func applyUpgrade(statName,value) -> void:
	print("Upgrade recieved.")
	print(statName," is being increased by ",value)
	self.set(statName, self.get(statName)+value)

func getUpgrades()->Array:
	var upgrades : Array = []
	var value = randi_range(ammoUpgradeRange[0],ammoUpgradeRange[1])
	upgrades.append({
		"gun": self,
		"stat": "maxAmmoCount",
		"upgradeName" : "Growth Enhancers",
		"value": value,
		"label":"%s, +%d max ammo." % [displayName,value]
	})
	value = randf_range(speedUpgradeRange[0],speedUpgradeRange[1])
	upgrades.append({
		"gun": self,
		"stat": "useSpeed",
		"upgradeName" : "Nose Candy",
		"value": value*-1,
		"label":"%s, %.3f increased firerate." % [displayName,value]
	})
	value = randi_range(cooldownUpgradeRange[0],cooldownUpgradeRange[1])
	upgrades.append({
		"gun": self,
		"stat": "reloadSpeed",
		"upgradeName" : "Steroids",
		"value": value*-1,
		"label":"%s, %d reduced reload time." % [displayName,value]
	})
	return upgrades
