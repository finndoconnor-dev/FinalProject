extends gun

@export var pelletCount : int = 10
@export var pelletSpread : float = 0.12
@export var pelletSpeedVariance : float = 0.05

@export var pelletCountUpgradeRange : Array = [0,0]
@export var pelletSpreadUpgradeRange: Array = [0.0,0.0]

func createProjectile() -> void:
	#print("Creating shotgun blast.")
	gunFired.emit()
	
	var parentScene = get_tree().current_scene
	
	for p in range(pelletCount):
		var proj = projectileScene.instantiate() as Node2D
		parentScene.add_child(proj)
		
		#move pellet to muzzle
		proj.global_position = projPoint.global_position
		proj.global_rotation = projPoint.global_rotation
		
		#random offset the rotation.
		proj.global_rotation += randf_range(-pelletSpread,pelletSpread)
		
		#random offset the speed.
		proj.speed += randf_range(-pelletSpeedVariance,pelletSpeedVariance)
		
func getUpgrades()->Array:
	var upgrades = super()
	#+ pellet count
	var value = randi_range(2,5)
	upgrades.append({
		"gun": self,
		"stat": "pelletCount",
		"upgradeName" : "???",
		"value": value,
		"label":"%s, -.%d increased pellet count." % [displayName,value]
	})
	#- spread
	value = randf_range(-0.005,0.01)
	upgrades.append({
		"gun": self,
		"stat": "pelletSpread",
		"upgradeName" : "???",
		"value": value,
		"label":"%s, -.%f3 increased pellet count." % [displayName,value]
	})
	return upgrades
