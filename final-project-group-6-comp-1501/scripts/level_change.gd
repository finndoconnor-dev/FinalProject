extends Area2D

@export var outgoingLevel : PackedScene

func _on_body_entered(body) -> void:
	if body.is_in_group("player"):
		if outgoingLevel != null:
			call_deferred("switchScene", body)  # <-- deferred

func _on_body_exited(body) -> void:
	pass

func switchScene(player : Node):
	var inv = get_tree().get_first_node_in_group("gunslot")
	inv.exportToLevelTransition()
	get_tree().change_scene_to_packed(outgoingLevel)
