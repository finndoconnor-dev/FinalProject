extends CanvasLayer

@onready var player = get_parent()
@onready var gunController = player.gunController

@onready var ammoCounter = $Panel/AmmoCounter
#@onready var nextGun = $Panel/NextGun
#@onready var currentGunName = $Panel/CurrentGun
@onready var HPBar = $Panel/HealthBar
@onready var gunSlots: Array[ProgressBar] = [
	$Panel/Slot1,
	$Panel/Slot2,
	$Panel/Slot3,
	$Panel/Slot4
]

func _ready() -> void:
	HPBar.max_value = player.maxHP
	HPBar.value = player.hitPoints
	HPBar.min_value = 0
	_configure_gun_slots()
	_update_gun_slots()

func _process(delta: float) -> void:
	if gunController != null:
		if gunController.currentGun != null:
#			currentGunName.text = gunController.currentGun.name
			ammoCounter.text = "%d/%d" % [gunController.currentGun.ammoCount, gunController.currentGun.maxAmmoCount]
		else:
			ammoCounter.text = "0/0"
#		if !gunController.gunQueue.is_empty():
##			nextGun.text = gunController.gunQueue[0].name
#		else:
#			nextGun.text = "Recharging!"
	_update_gun_slots()

func updateHealthbar(newHP : int) -> void:
	HPBar.value = newHP


func _on_player_took_damage() -> void:
	updateHealthbar(player.hitPoints)


func _configure_gun_slots() -> void:
	for slot in gunSlots:
		slot.min_value = 0.0
		slot.max_value = 1.0
		slot.value = 0.0
		var gun_texture := slot.get_node("TextureRect") as TextureRect
		gun_texture.custom_minimum_size = Vector2(35, 35)
		gun_texture.size = Vector2(35, 35)
		gun_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		gun_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED


func _update_gun_slots() -> void:
	for slot_index in range(gunSlots.size()):
		var slot := gunSlots[slot_index]
		var gun_texture := slot.get_node("TextureRect") as TextureRect
		var inventory_gun := _get_gun_for_slot(slot_index)

		if inventory_gun == null:
			gun_texture.texture = null
			slot.value = 0.0
			continue

		gun_texture.texture = _get_gun_texture(inventory_gun)
		slot.value = _get_queue_cooldown_progress(inventory_gun)


func _get_gun_for_slot(slot_index: int) -> gun:
	if gunController == null:
		return null
	if slot_index >= gunController.gunInventory.size():
		return null
	return gunController.gunInventory[slot_index]


func _get_gun_texture(inventory_gun: gun) -> Texture2D:
	if inventory_gun == null or inventory_gun.gunRotate == null:
		return null

	for child in inventory_gun.gunRotate.get_children():
		if child is Sprite2D:
			return child.texture

	return null


func _get_queue_cooldown_progress(inventory_gun: gun) -> float:
	if inventory_gun == null or inventory_gun.queueCooldown == null:
		return 0.0
	if inventory_gun.reloadSpeed <= 0.0:
		return 1.0

	var cooldown_timer := inventory_gun.queueCooldown
	if cooldown_timer.is_stopped():
		return 1.0

	var wait_time := cooldown_timer.wait_time
	if wait_time <= 0.0:
		return 1.0

	return clamp((wait_time - cooldown_timer.time_left) / wait_time, 0.0, 1.0)
