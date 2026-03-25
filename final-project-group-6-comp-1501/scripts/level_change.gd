extends Area2D

@export var outgoingLevel : PackedScene

	
func _on_body_entered(body) -> void:
	print("Level Exit Entered.")
	if body.is_in_group("player"):
		if (outgoingLevel != null):
			switchScene(outgoingLevel)
	
func _on_body_exited(body) -> void:
	print("Level Exit Extitted")


func switchScene(player : PackedScene):
	get_tree().change_scene_to_packed(outgoingLevel)
	
	
