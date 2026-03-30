extends baseEnemy

func takeStopAction() -> void:
	canMove = false
	shootTimer.start()

func takeMoveAction() -> void:
	canMove = true
	shootTimer.stop()

func _on_shot_timer_timeout() -> void:
	gunNode.tryShoot()
	#print("trying to shoot")
