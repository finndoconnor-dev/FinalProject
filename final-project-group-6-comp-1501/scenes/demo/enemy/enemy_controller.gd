extends Node2D

@export var enemyPrefabArray : Array[PackedScene]
@export var gunPrefabArray : Array[PackedScene]
@export var target : Node2D

@export var enemyCount=50
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawnEnemies()
	
#Adds an enemy at a random spot the paramaters still need to be adjusted
func spawnEnemies():
	for i in enemyCount:
		var enemy = enemyPrefabArray[randi_range(0,enemyPrefabArray.size()-1)].instantiate()
		enemy.player=target
		
		#this should be changed eventually
		enemy.global_position=Vector2(randi_range(500,550),randi_range(100,400))
		
		var gun = gunPrefabArray[randi_range(0,gunPrefabArray.size()-1)].instantiate()
		enemy.add_child(gun)
		gun.get_node("GunRotate").target=target
		gun.get_node("GunRotate").useMouse=false
		gun.attachedToPlayer=false
		add_child(enemy)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
