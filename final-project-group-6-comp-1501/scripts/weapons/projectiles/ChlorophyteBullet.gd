extends projectile

@export var homing_range: float = 320.0
@export var turn_speed: float = 7.5
@export var retarget_interval: float = 0.1

var current_target = null
var retarget_timer := 0.0

func _ready() -> void:
	self.attack.damagesNPC = true
	self.attack.damage = self.damage
	self.attack.pierces = true
	self.attack.triggerInvulnerability = true
	super()


func _physics_process(delta: float) -> void:
	retarget_timer -= delta
	if retarget_timer <= 0.0 or !_is_valid_target(current_target):
		current_target = _find_target()
		retarget_timer = retarget_interval

	if _is_valid_target(current_target):
		var target := current_target as Node2D
		var desired_rotation := global_position.angle_to_point(target.global_position)
		global_rotation = lerp_angle(global_rotation, desired_rotation, min(turn_speed * delta, 1.0))

	global_position += Vector2.from_angle(global_rotation) * speed


func _find_target() -> Node2D:
	var scene_root := get_tree().current_scene
	if scene_root == null:
		scene_root = get_tree().root

	var best_target: Node2D = null
	var best_distance_squared := homing_range * homing_range

	for candidate in _collect_targets(scene_root):
		var distance_squared := global_position.distance_squared_to(candidate.global_position)
		if distance_squared > best_distance_squared:
			continue
		best_distance_squared = distance_squared
		best_target = candidate

	return best_target


func _collect_targets(node: Node) -> Array[Node2D]:
	var targets: Array[Node2D] = []

	for child in node.get_children():
		if child is Node2D:
			var candidate := child as Node2D
			if _is_valid_target(candidate):
				targets.append(candidate)
		targets.append_array(_collect_targets(child))

	return targets


func _is_valid_target(target) -> bool:
	if target == null or !is_instance_valid(target):
		return false
	if !(target is Node2D):
		return false
	var node := target as Node2D
	if node == self:
		return false
	if node.is_in_group("player"):
		return false
	return node.has_method("onDamage")
