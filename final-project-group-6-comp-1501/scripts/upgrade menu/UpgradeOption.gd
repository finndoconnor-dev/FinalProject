extends Button

#@onready var upgradeNameLabel = $MarginContainer/VBoxContainer/UpgradeName
#@onready var upgradeDescLabel = $MarginContainer/VBoxContainer/UpgradeDescription

var upgradeData : Dictionary

signal upgradeSelected

func _ready() -> void:
	pass

func setUpgradeOption(data : Dictionary)->void:
	print("Creating button with data")
	print(data)
	upgradeData = data
	self.text = str(upgradeData.get("upgradeName")) + "\n" + str(upgradeData.get("label"))
	#upgradeNameLabel.text = str(upgradeData.get("upgradeName"))
	#upgradeDescLabel.text = str(upgradeData.get("label"))

func _pressed():
	print("Upgrade Selected")
	upgradeSelected.emit(upgradeData)
