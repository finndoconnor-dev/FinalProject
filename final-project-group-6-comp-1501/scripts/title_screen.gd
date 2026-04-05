extends Control

@export var outgoing : PackedScene

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_packed(outgoing)
