extends Node2D

var ammo=0

@export var gun_scenes: Array[PackedScene]
@export var queueDelay : float = 0.05
@onready var gunQueue: Array[gun]

var currentGun : gun

func _ready() -> void:
	for i in range(gun_scenes.size()):
		addNewGunToQueue(gun_scenes[i])
	cycleGun()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if currentGun == null: return

	if currentGun.isEmpty():
		print("Gun empty... Cycling gun...")
		cycleGun()
	if Input.is_action_just_pressed("q"):
		cycleGun()

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("left_click"):
		#print("Trying to shoot "+currentGun.name)
		if currentGun != null:
			currentGun.tryShoot()
			#print(currentGun.ammoCount)

func cycleGun():
	if currentGun != null: #Reload old gun and return it to queue
		currentGun.reload()
		gunQueue.append(currentGun)
		remove_child(currentGun)
	await get_tree().create_timer(queueDelay).timeout
	currentGun = gunQueue.pop_front() #Pull new gun from front of the queue
	print("Queuing Gun " + currentGun.name)
	add_child(currentGun)

func addNewGunToQueue(newGun : PackedScene):
	var i = newGun.instantiate() as gun
	if i == null:
		print("Failed to instantiate gun "+ newGun.name)
	gunQueue.append(i)

	#if ammo<=0:
		#gunQueue[currentIndex].gunFired.disconnect(_on_gun_fired)
		#gunQueue[currentIndex].queue_free()
		#currentIndex+=1
		#if currentIndex>=4:
			#newQueue()
		#print("Gun changed!!!")
		#self.add_child(gunQueue[currentIndex])
		#gunQueue[currentIndex].gunFired.connect(_on_gun_fired)
		#ammo=gunQueue[currentIndex].ammoCount

#func _on_gun_fired() -> void:
	#print(ammo)
	#ammo-=1

#func newQueue():
	#currentIndex=0
	#for i in range(4):
		#print(i)
		#gunIndex=randi_range(0,3)
		#gunQueue[i]=gun_scenes[gunIndex].instantiate()
