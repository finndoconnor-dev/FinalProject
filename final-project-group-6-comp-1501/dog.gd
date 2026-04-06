extends Node2D

@export var speed=150

func _process(delta: float) -> void:
	position.y -= speed*delta
	$AnimatedSprite2D.play("runAway")
	await get_tree().create_timer(1.0).timeout
	$AudioStreamPlayer.play()
	await get_tree().create_timer(2.0).timeout
	$AudioStreamPlayer.stop()
	
