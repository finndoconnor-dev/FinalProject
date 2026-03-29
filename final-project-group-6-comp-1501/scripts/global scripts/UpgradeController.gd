extends Node

const upgradeMenu = preload("res://scenes/demo/weapons/upgrade menu/UpgradeMenu.tscn")

var player : Node

var nextUpgrade: int = 1 #current number of kills needed for an upgrade
var enemiesKilled : int = 0  #Enemy kill count.
var upgradeIncrement : int = 1 #next number of kills needed for an upgrade
var upgradeCurve : float #how much each goal increases per upgrade -> more upgrade = more kills needed for next


func _ready() -> void:
	self.process_mode = PROCESS_MODE_ALWAYS
	print("Upgrade System Initialized.")
	
func _physics_process(delta: float) -> void:
	if (enemiesKilled >= nextUpgrade):
		print("Upgrade Aquired.")
		nextUpgrade += upgradeIncrement
		initUpgradeMenu()
	if Input.is_action_just_pressed("1"):
		initUpgradeMenu()

func _on_enemyDied():
	enemiesKilled +=1
	print("Enemy killed.")

func setPlayer(player : Node):
	self.player = player

func getPlayerWeapons() -> Array[Node]:
	var guns : Array[Node] = []
	var equipSlot = player.get_node("EquipSlot")
	for index in range(equipSlot.gunInventory.size()):
		guns.append(equipSlot.gunInventory[index])
		print("Grabbed ",equipSlot.gunInventory[index].displayName," from player and added to upgrade list.")
	return guns

func initUpgradeMenu():
	var menu = upgradeMenu.instantiate()
	get_tree().current_scene.add_child(menu)
	get_tree().paused = true
	menu.setGuns(getPlayerWeapons())
	menu.upgradeSelected.connect(_on_upgradeSelected)
	menu.start()
	
func _on_upgradeSelected(upgradeData : Dictionary):
	print("Upgrade receieved by controller: ",upgradeData)
	var gunToUpgrade = upgradeData.get("gun")
	gunToUpgrade.applyUpgrade(upgradeData.get("stat"),upgradeData.get("value"))
	get_tree().paused = false
