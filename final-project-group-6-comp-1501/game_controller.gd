extends Node
signal gamePaused

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("pause"):
		pauseGame()

func pauseGame():
	get_tree().paused=true
	$PauseMenu.visible=true
	$DemoLevel/YsortingContainer/Player/PlayerHUD.hide()
	gamePaused.emit()


func _on_pause_menu_resumed() -> void:
	$DemoLevel/YsortingContainer/Player/PlayerHUD.visible=true
