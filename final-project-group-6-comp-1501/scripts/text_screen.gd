extends Control

@export var outgoing : PackedScene

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_packed(outgoing)
