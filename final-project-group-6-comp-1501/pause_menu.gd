extends CanvasLayer
signal resumed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_resume_button_pressed() -> void:
	get_tree().paused=false;
	self.hide()
	resumed.emit()


func _on_controls_button_pressed() -> void:
	$ControlPanel.show()
	$ResumeButton.hide()
	$ControlsButton.hide()
	


func _on_controls_exit_button_pressed() -> void:
	$ControlPanel.hide()
	$ResumeButton.show()
	$ControlsButton.show()
