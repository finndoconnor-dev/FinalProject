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
@onready var sound : AudioStreamPlayer2D = $sound
@onready var queueCooldown : Timer = Timer.new()

signal gunFired
signal addToQueue(gun)

var ammoCount : int = maxAmmoCount

var shootFunctionPointer : Callable


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shootFunctionPointer = defaultProjectile
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
	if (useSpeed > 0): cooldownTimer.start(useSpeed)
	ammoCount -= 1
	gunFired.emit()
	sound.play()
	shootFunctionPointer.call()
	
func defaultProjectile() -> void:
	#print("Creating projectile.")
	gunFired.emit()
	var proj := projectileScene.instantiate() as Node2D
	get_tree().current_scene.add_child(proj)
	proj.global_transform = projPoint.global_transform

#Cooldown methods --------------------------------------------------
func onCooldown() -> void:
	ammoCount = maxAmmoCount
	if (reloadSpeed < 0): addToQueue.emit(self)
	queueCooldown.start(reloadSpeed)

func offCooldown() -> void:
	print(displayName + " is off cooldown.")
	addToQueue.emit(self)
#Upgrade methods ---------------------------------------------------	
func applyUpgrade(upgradeData : Dictionary) -> void:
	print("Upgrade recieved.")
	#Simple stat changes
	if (upgradeData.has("stat")):
		var current = self.get(upgradeData["stat"])
		var new = current + (upgradeData["value"])
		print("Modifying stat: ",upgradeData["stat"])
		print("Original value ",current)
		print("Increasing by ",upgradeData["value"])
		print("New value ",new)
		self.set(upgradeData["stat"],new)
		
	#Complex stat changes
	if (upgradeData.has("apply")): upgradeData["apply"].call(self)

func _get_percent_upgrade_amount(current_stat: float, percent_range: Array) -> float:
	var percent := randf_range(percent_range[0], percent_range[1])
	return current_stat * (percent / 100.0)

func _get_percent_upgrade_int_amount(current_stat: int, percent_range: Array) -> int:
	var amount := _get_percent_upgrade_amount(current_stat, percent_range)
	return maxi(1, int(round(amount)))

func getUpgrades()->Array:
	var upgrades : Array = []
	var value = _get_percent_upgrade_int_amount(maxAmmoCount, ammoUpgradeRange)
	upgrades.append({
		"gun": self,
		"stat": "maxAmmoCount",
		"upgradeName" : "Growth Enhancers",
		"value": value,
		"label":"%s, +%d max ammo." % [displayName,value]
	})
	value = -_get_percent_upgrade_amount(useSpeed, speedUpgradeRange)
	var firerate_percent := 0.0
	if useSpeed > 0 and (useSpeed + value) > 0:
		firerate_percent = (((1.0 / (useSpeed + value)) - (1.0 / useSpeed)) / (1.0 / useSpeed)) * 100.0
		upgrades.append({
			"gun": self,
			"stat": "useSpeed",
			"upgradeName" : "Nose Candy",
			"value": value,
			"label":"%s, %.2f%% increased firerate." % [displayName,firerate_percent]
		})
	value = -_get_percent_upgrade_amount(reloadSpeed, cooldownUpgradeRange)
	var reload_percent := 0.0
	if reloadSpeed > 0:
		reload_percent = absf(value) / reloadSpeed * 100.0
		upgrades.append({
			"gun": self,
			"stat": "reloadSpeed",
			"upgradeName" : "Steroids",
			"value": value,
			"label":"%s, %.2f%% reduced reload time." % [displayName,reload_percent]
		})
	return upgrades
