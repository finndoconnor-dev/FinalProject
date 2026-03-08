extends gun

func createProjectile() -> void:
	print("Creating projectile.")
	gunFired.emit()
	var proj := projectileScene.instantiate() as Node2D
	get_tree().current_scene.add_child(proj)
	proj.global_transform = projPoint.global_transform
