extends Node2D

@export var enemyPrefabArray : Array[PackedScene]
@export var target : Node2D
@onready var spawnPoints=$SpawnPointsStage1.get_children()

@export var enemyCount : int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemyCount=spawnPoints.size()
	spawnEnemies()
	
#Adds an enemy at a random spot the paramaters still need to be adjusted
func spawnEnemies():
	for i in enemyCount:
		var enemy = enemyPrefabArray[randi_range(0,enemyPrefabArray.size()-1)].instantiate() #spwans a random enemy from the array
		enemy.player=target
		enemy.global_position=spawnPoints[i].global_position
		add_child(enemy)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
