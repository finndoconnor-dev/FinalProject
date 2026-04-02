extends Node2D

@export var rareEnemy : PackedScene
@export var commonEnemy : PackedScene
#@export var target : Node2D
#@onready var spawnPoints=$SpawnPointsStage1.get_children()
@onready var spawnPosition = $Marker2D
@onready var triggerArea = $TriggerRadius

@export var enemyCount : int
@export var timeBetweenSpawns : float = 0.25
@export var spawnRadius : float = 50.0

var has_spawned := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Hoard Spawner initialized.")
	pass
	
#Adds an enemy at a random spot the paramaters still need to be adjusted
func spawnEnemies():
	print("Spawner triggered, spawning enemies...")
	var spawn_parent := get_parent()
	for i in range(enemyCount):
		print("Attempting to spawn enemy ",i)
		#var enemy = enemyPrefabArray[randi_range(0,enemyPrefabArray.size()-1)].instantiate() #spwans a random enemy from the array
		var enemy = pickEnemy().instantiate()
		spawn_parent.add_child(enemy)
		if enemy is Node2D:
			enemy.global_position = get_random_spawn_position()
		await get_tree().create_timer(timeBetweenSpawns).timeout

func get_random_spawn_position() -> Vector2:
	var angle := randf() * TAU
	var distance := sqrt(randf()) * spawnRadius
	var local_offset := Vector2.RIGHT.rotated(angle) * distance
	return spawnPosition.global_position + local_offset

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func pickEnemy() -> PackedScene:
	var r = randi_range(1,20)
	if (r >= 16):
		return rareEnemy
	else:
		return commonEnemy


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and !has_spawned:
		has_spawned = true
		spawnEnemies()
