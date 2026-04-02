extends Node2D

var player : Node2D #pointer to player node
var validPlayer : bool = false #flag for when getPlayer() got the level's player successfully.

func _ready() -> void :
	player = getPlayer()
	if !validPlayer:
		print("No valid player for AmbushSpawner")

func getPlayer() -> Node2D:
	var p = get_tree().get_first_node_in_group("player")
	if p == null:
		validPlayer = false
		return null
	else:
		validPlayer = true
		return p
