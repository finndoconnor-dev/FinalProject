extends Node2D
@export var map_scene: PackedScene
@onready var mapPaths: Array[String]=["res://scenes/demo/level/level_1S1.tscn","res://scenes/demo/level/level_1s_2.tscn"]
@export var mapCount=0
signal mapChanged
var map: Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map_scene=load(mapPaths[mapCount])
	map=map_scene.instantiate()
	map.mapExited.connect(changeMap)
	self.add_child(map)

func changeMap():
	self.remove_child(map)
	map.disconnect("mapExited",changeMap)
	mapCount+=1
	map_scene=load(mapPaths[mapCount])
	map=map_scene.instantiate()
	self.add_child(map)
	mapChanged.emit()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
