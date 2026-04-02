extends gun

@export var mutationProjectiles : Array[PackedScene]

@onready var trishotPointA = $GunRotate/Trishot1
@onready var trishotPointB = $GunRotate/Trishot2

var mutated : bool = false

func trishotProjectile():
	gunFired.emit()
	var proj1 := projectileScene.instantiate() as Node2D
	get_tree().current_scene.add_child(proj1)
	proj1.global_transform = trishotPointA.global_transform
	proj1.global_rotation_degrees -= 15
	var proj2 := projectileScene.instantiate() as Node2D
	get_tree().current_scene.add_child(proj2)
	proj2.global_transform = projPoint.global_transform
	var proj3 := projectileScene.instantiate() as Node2D
	get_tree().current_scene.add_child(proj3)
	proj3.global_transform = trishotPointB.global_transform
	proj3.global_rotation_degrees += 15

	


func getUpgrades()->Array:
	var upgrades = super()
	if !mutated:
		upgrades.append({
			"gun": self,
			"upgradeName" : "Mutation: Enhanced Cheek Pouches",
			"label":"Big acorns means high damage and low projectile speed.",
			"apply": func(gun):
				gun.projectileScene = mutationProjectiles[0]
				mutated = true
		})
		upgrades.append({
			"gun": self,
			"upgradeName" : "Mutation: Three heads",
			"label":"Your squirrel has three heads to shoot three acorns... Gross.",
			"apply": func(gun):
				gun.shootFunctionPointer = trishotProjectile
				mutated = true
		})
	return upgrades
