extends Node2D

@export var enemyPrefabArray : Array[PackedScene]
@export var testEnemy : PackedScene
#@export var target : Node2D
#@onready var spawnPoints=$SpawnPointsStage1.get_children()
@onready var spawnPosition = $Marker2D

@export var enemyCount : int
@export var timeBetweenSpawns : float = 0.25
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Hoard Spawner initialized.")
	pass
	
#Adds an enemy at a random spot the paramaters still need to be adjusted
func spawnEnemies():
	print("Spawner triggered, spawning enemies...")
	for i in enemyCount:
		print("Attempting to spawn enemy ",i)
		var enemy = enemyPrefabArray[randi_range(0,enemyPrefabArray.size()-1)].instantiate() #spwans a random enemy from the array
		enemy.global_position = spawnPosition.global_position
		add_child(enemy)
		await get_tree().create_timer(timeBetweenSpawns).timeout

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.is_in_group("player")):
		spawnEnemies()
