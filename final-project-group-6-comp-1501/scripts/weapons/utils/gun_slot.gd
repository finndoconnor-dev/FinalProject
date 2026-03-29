extends Node2D

var ammo=0

@export var gunScenes: Array[PackedScene]
@export var queueDelay : float = 0.05
@onready var gunInventory : Array[gun] #The copy of the gun nodes that will process the cooldown
@onready var gunQueue: Array[gun] #Gun nodes queued to be used.

var currentGun : gun

func _ready() -> void :
	for i in range(gunScenes.size()) :
		addToInventory(gunScenes[i].instantiate())
	print("Gun inventory initialized.")

func _physics_process(delta: float) -> void:
	if currentGun != null:
		if Input.is_action_pressed("left_click"):
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
	if gunQueue.is_empty(): return
	if currentGun == null:
		currentGun = gunQueue.pop_front()
		currentGun.visible = true
	else:
		currentGun.visible = false #This should be the OLD gun pointer, and make the OLD gun invisible.
		currentGun.onCooldown()
		currentGun = gunQueue.pop_front() #This should switch to the NEW gun pointer.
		currentGun.visible = true #This should point to the NEW gun and make is visible.

func addToInventory(item : gun) -> void :
	print("adding to inventory: "+item.name)
	add_child(item)
	item.visible = false
	gunInventory.append(item)
	item.addToQueue.connect(addToQueue)

func addToQueue(item : gun) -> void :
	#print("adding to queue: "+item.name)
	gunQueue.append(item)





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
