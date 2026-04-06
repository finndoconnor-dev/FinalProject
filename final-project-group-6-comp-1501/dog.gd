extends Node2D

@export var runSpeed=150

var hasPlayed = false
var speed = 0

func _ready() -> void:
	bark()
	await get_tree().create_timer(1.5).timeout
	speed = runSpeed

func _process(delta: float) -> void:
	position.y -= speed*delta
	$AnimatedSprite2D.play("runAway")
	#if !hasPlayed:
		#bark()
	if (position.y < -1500):
		queue_free()
	
func bark() -> void:
	$AudioStreamPlayer.play()
	
