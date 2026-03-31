extends CanvasLayer

@export var optionScene : PackedScene #Set to upgrade option
@export var numberOfOptions : int
@onready var buttonContainer = $Control/GridContainer

var availableGuns : Array[Node]
var upgradeList : Array[Dictionary]

signal upgradeSelected(Dictionary)

func _ready() -> void:
	process_mode = PROCESS_MODE_WHEN_PAUSED
	print("Menu Initialized.")
	pass

func start() -> void:
	if availableGuns.is_empty(): print("No guns to create a menu!"); return
	generateUpgradeList()
	#print("Selecting ",numberOfOptions," random upgrades...")
	var rng = getRandomIndexes(upgradeList.size(),numberOfOptions)
	var options = []
	for i in range(rng.size()):
		options.append(upgradeList[rng[i]])
	createButtons(options)

func selectUpgrade(upgrade : Dictionary):
	print("Upgrade receieved by menu: ", upgrade)
	upgradeSelected.emit(upgrade)
	self.queue_free()
	
func setGuns(newGuns : Array[Node]):
	availableGuns.clear()
	availableGuns.append_array(newGuns)
	#print("Guns added to menu successfully : ",availableGuns)

func generateUpgradeList():
	for i in range(availableGuns.size()):
		upgradeList.append_array(availableGuns[i].getUpgrades())
	#print("Generated upgrade list: ",upgradeList)

func createButtons(options : Array):
	for i in range(options.size()):
		var button = optionScene.instantiate()
		buttonContainer.add_child(button)
		button.setUpgradeOption(options[i])
		button.upgradeSelected.connect(selectUpgrade)

func getRandomIndexes(maxValue : int, count : int) -> Array:
	var numbers  = []
	for i in range(maxValue):
		numbers.append(i)
	numbers.shuffle()
	return numbers.slice(0,count)
	
	
