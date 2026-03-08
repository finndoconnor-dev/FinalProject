extends CanvasLayer

@onready var player = get_parent()
@onready var gunController = player.gunController

@onready var ammoCounter = $Panel/AmmoCounter
@onready var nextGun = $Panel/NextGun
@onready var currentGunName = $Panel/CurrentGun

func _process(delta: float) -> void:
	if gunController != null:
		if gunController.currentGun != null:
			currentGunName.text = gunController.currentGun.name
			ammoCounter.text = "%d/%d" % [gunController.currentGun.ammoCount, gunController.currentGun.maxAmmoCount]
		if !gunController.gunQueue.is_empty():
			nextGun.text = gunController.gunQueue[0].name
