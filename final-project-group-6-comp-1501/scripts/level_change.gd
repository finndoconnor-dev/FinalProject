extends Area2D

@export var outgoingLevel : PackedScene

func _on_body_entered(body) -> void:
	print("Level Exit Entered.")
	if body.is_in_group("player"):
		if (outgoingLevel != null):
			switchScene(body)
	
func _on_body_exited(body) -> void:
	pass
	#print("Level Exit Extitted")


func switchScene(player : Node):
	var inv = get_tree().get_first_node_in_group("gunslot")
	inv.exportToLevelTransition()
	
	
	get_tree().change_scene_to_packed(outgoingLevel)
	
