extends Node

var upgradeThreshold : int
var upgradeRampRate : int
var playerKillCount : int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("enemyDied", _on_enemyDied)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_enemyDied() -> void:
	playerKillCount += 1;
	print("Enemy Killed...")
	print(playerKillCount)
