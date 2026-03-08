extends Node2D

var target : Node2D   # the node to aim at
var useMouse := true # if true, aim at mouse instead

func _process(delta):
	if useMouse:
		look_at(get_global_mouse_position())
	elif target != null:
		look_at(target.global_position)
	adjustVisuals()
	
func adjustVisuals() -> void:
	self.rotation_degrees = wrap(self.rotation_degrees, 0,360)
	if (self.rotation_degrees > 90 && self.rotation_degrees < 270):
		self.scale.y = -1
	else:
		self.scale.y = 1
