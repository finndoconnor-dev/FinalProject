extends enemyGun

func createProjectile() -> void:
	for i in range(4):
		var proj = projectileScene.instantiate()
		get_tree().root.add_child(proj)
		proj.global_position = exitPoint.global_position
		proj.global_rotation = exitPoint.global_rotation+(i-1.5)/(PI)
		
		
