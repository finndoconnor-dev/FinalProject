extends gun

@export var mutationProjectile : PackedScene
@export var bulletSpread : float = 0.12
@export var bulletSpeedVariance : float = 0.05

var mutated = false

func _ready() -> void:
	super()
	shootFunctionPointer = createProjectile

func createProjectile() -> void:
	#print("Creating shotgun blast.")
	gunFired.emit()
	
	var parentScene = get_tree().current_scene
	var proj = projectileScene.instantiate() as Node2D
	parentScene.add_child(proj)
	#move pellet to muzzle
	proj.global_position = projPoint.global_position
	proj.global_rotation = projPoint.global_rotation
	#random offset the rotation.
	proj.global_rotation += randf_range(-bulletSpread,bulletSpread)
	#random offset the speed.
	proj.speed += randf_range(-bulletSpeedVariance,bulletSpeedVariance)

func getUpgrades()->Array:
	var upgrades = super()
	if !mutated:
		upgrades.append({
			"gun": self,
			"upgradeName" : "Mutation: Chlorophyte Bullets",
			"label":"If you know, you know.",
			"apply": func(gun):
				gun.projectileScene = mutationProjectile
				gun.reloadSpeed *= 2
				mutated = true
		})
	return upgrades
