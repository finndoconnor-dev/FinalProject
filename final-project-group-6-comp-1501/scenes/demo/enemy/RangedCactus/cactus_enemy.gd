extends baseEnemy

func takeStopAction() -> void:
	canMove = false
	shootTimer.start()
	gunNode.tryShoot()

func takeMoveAction() -> void:
	canMove = true
	shootTimer.stop()
	animatedSprite.play("run")

func _on_shot_timer_timeout() -> void:
	gunNode.tryShoot()
	animatedSprite.play("attack")
