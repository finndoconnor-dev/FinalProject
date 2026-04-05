extends gun

@export var mutationProjectiles : Array[PackedScene]
@export var shotgunSpread : float = 22
@export var shotgunCount : int = 7

var mutated : bool = false

func shotgunProjectile():
	for i in range(shotgunCount):
		var proj1 := projectileScene.instantiate() as Node2D
		get_tree().current_scene.add_child(proj1)
		proj1.global_transform = projPoint.global_transform
		proj1.global_rotation_degrees += randf_range(-shotgunSpread,shotgunSpread)

func oneshotProjectile():
	var proj1 := projectileScene.instantiate() as Node2D
	get_tree().current_scene.add_child(proj1)
	proj1.global_transform = projPoint.global_transform
	proj1.attack.damage = maxAmmoCount * 16
	self.ammoCount = 0


func getUpgrades()->Array:
	var upgrades = super()
	if !mutated:
		upgrades.append({
			"gun": self,
			"upgradeName" : "Mutation: One shot, one kill",
			"label":"Immense damage, but uses all ammo at once. Scales with max ammo.",
			"apply": func(gun):
				gun.shootFunctionPointer = oneshotProjectile
				gun.mutated = true
		})
		upgrades.append({
			"gun": self,
			"upgradeName" : "Mutation: Boa Blaster",
			"label":"Your Snake Sniper is converted into a shotgun.",
			"apply": func(gun):
				gun.projectileScene = gun.mutationProjectiles[0]
				gun.shootFunctionPointer = shotgunProjectile
				gun.mutated = true
		})
	return upgrades
