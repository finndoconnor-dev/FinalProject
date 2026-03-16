extends Node2D
class_name enemyGun

@export var maxAmmoCount : int = -1  # -1 = infinite ammo
@export var projectileScene : PackedScene = null

@onready var gunRotate : Node2D = $GunRotate
@onready var exitPoint : Node2D = $GunRotate/ExitPoint

signal gunFired

var ammoCount : int = 0
var inRange : bool

func _ready() -> void:
	ammoCount = maxAmmoCount

func isEmpty() -> bool:
	if maxAmmoCount == -1: return false
	return ammoCount <= 0

func tryShoot() -> void:
	if projectileScene == null:
		print(self.name + " has no attached projectile scene")
		return
	if isEmpty():
		return
	if maxAmmoCount != -1:
		ammoCount -= 1
	gunFired.emit()
	createProjectile()

func createProjectile() -> void:
	var proj = projectileScene.instantiate()
	get_tree().root.add_child(proj)
	proj.global_position = exitPoint.global_position
	proj.global_rotation = exitPoint.global_rotation
