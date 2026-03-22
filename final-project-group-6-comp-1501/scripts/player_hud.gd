extends CanvasLayer

@onready var player = get_parent()
@onready var gunController = player.gunController

@onready var ammoCounter = $Panel/AmmoCounter
@onready var nextGun = $Panel/NextGun
@onready var currentGunName = $Panel/CurrentGun
@onready var HPBar = $Panel/HealthBar

func _ready() -> void:
	HPBar.max_value = player.maxHP
	HPBar.value = player.hitPoints
	HPBar.min_value = 0

func _process(delta: float) -> void:
	if gunController != null:
		if gunController.currentGun != null:
			currentGunName.text = gunController.currentGun.name
			ammoCounter.text = "%d/%d" % [gunController.currentGun.ammoCount, gunController.currentGun.maxAmmoCount]
		if !gunController.gunQueue.is_empty():
			nextGun.text = gunController.gunQueue[0].name

func updateHealthbar(newHP : int) -> void:
	HPBar.value = newHP


func _on_player_took_damage() -> void:
	updateHealthbar(player.hitPoints)
