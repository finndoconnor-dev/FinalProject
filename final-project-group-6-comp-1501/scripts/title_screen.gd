extends Control

@export var outgoing : PackedScene
const DEFAULT_OUTGOING_PATH := "res://scenes/text_screen.tscn"

func _ready() -> void:
	get_tree().paused = false
	
	
func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()


func _on_start_game_pressed() -> void:
	get_tree().paused = false
	call_deferred("_change_to_outgoing")


func _change_to_outgoing() -> void:
	var outgoing_path := DEFAULT_OUTGOING_PATH
	if outgoing != null and outgoing.resource_path != "":
		outgoing_path = outgoing.resource_path
	get_tree().change_scene_to_file(outgoing_path)
