extends Node2D

var ammo=0

@export var gunScenes: Array[PackedScene]
@export var queueDelay : float = 0.05
@onready var gunInventory : Array[gun] #The copy of the gun nodes that will process the cooldown
@onready var gunQueue: Array[gun] #Gun nodes queued to be used.

var currentGun : gun
var waiting_for_shoot_release := false

func _ready() -> void :
	add_to_group("gunslot")
	if (!importFromLevelTransition()):
		for i in range(gunScenes.size()) :
			addToInventory(gunScenes[i].instantiate())
	print("Gun inventory initialized.")

func _physics_process(delta: float) -> void:
	if waiting_for_shoot_release and !Input.is_action_pressed("left_click"):
		waiting_for_shoot_release = false

	if currentGun != null:
		if !waiting_for_shoot_release and Input.is_action_pressed("left_click"):
			#print("Trying to shoot "+currentGun.name)
				currentGun.tryShoot()
				#print(currentGun.ammoCount)
		if currentGun.isEmpty():
			#print("Gun empty... Cycling gun...")
			cycleGun()
		if Input.is_action_just_pressed("q"):
			cycleGun()
	else: cycleGun()

func cycleGun() -> void :
	var previousGun := currentGun

	#Player doesn't have a gun, but theres a gun in queue.
	#print(gunQueue)
	if currentGun == null:
		if !gunQueue.is_empty():
			currentGun = gunQueue.pop_front()
			currentGun.visible = true
			_lock_shooting_until_release(previousGun)
		return

	#The player has a gun, but theres no gun in queue.
	if gunQueue.is_empty():
		currentGun.onCooldown()
		currentGun.visible = false
		currentGun = null
		return

	#Regular gun switch -> Player has a gun, theres a gun in queue
	currentGun.visible = false #This should be the OLD gun pointer, and make the OLD gun invisible.
	currentGun.onCooldown()
	currentGun = gunQueue.pop_front() #This should switch to the NEW gun pointer.
	currentGun.visible = true #This should point to the NEW gun and make is visible.
	_lock_shooting_until_release(previousGun)

func _lock_shooting_until_release(previousGun: gun) -> void:
	if previousGun != null and Input.is_action_pressed("left_click"):
		waiting_for_shoot_release = true

func addToInventory(item : gun) -> void :
	print("adding to inventory: "+item.name)
	add_child(item)
	item.visible = false
	gunInventory.append(item)
	item.addToQueue.connect(addToQueue)
	item.onCooldown()

func addToQueue(item : gun) -> void :
	#print("adding to queue: "+item.name)
	gunQueue.append(item)
	print(gunQueue)

func exportToLevelTransition() -> void:
	for i in gunInventory:
		remove_child(i)
		levelTransitionController.saveGunToCache(i)

func importFromLevelTransition() -> bool:
	if (levelTransitionController.playerInventory.size() <= 0):
		print("Didn't find any saved data.")
		return false
	else:
		var data = levelTransitionController.loadGunsFromCache()
		for i in data:
			addToInventory(i)
		print("Found saved data.")
		return true


#func _ready() -> void:
	#for i in range(gun_scenes.size()):
		#gunList.append(gun_scenes[i])
		#addNewGunToQueue(gun_scenes[i])
	#cycleGun()
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#if currentGun == null: return

#
#func _physics_process(delta: float) -> void:
	#if Input.is_action_pressed("left_click"):
		##print("Trying to shoot "+currentGun.name)
		#if currentGun != null:
			#currentGun.tryShoot()
			##print(currentGun.ammoCount)
#
#func cycleGun():
	#if currentGun != null: #Reload old gun and return it to queue
		#currentGun.reload()
		#gunQueue.append(currentGun)
		#remove_child(currentGun)
	#await get_tree().create_timer(queueDelay).timeout
	#currentGun = gunQueue.pop_front() #Pull new gun from front of the queue
	#print("Queuing Gun " + currentGun.name)
	#add_child(currentGun)
#
#func addNewGunToQueue(newGun : PackedScene):
	#var i = newGun.instantiate() as gun
	#if i == null:
		#print("Failed to instantiate gun "+ newGun.name)
	#gunQueue.append(i)
