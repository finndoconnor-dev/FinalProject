extends Area2D
class_name projectile


@export var speed: float = 900.0
@export var lifetime: float = 2.0
@export var damage : float = 15

@onready var hitBox = $CollisionShape2D
@onready var attack = Attack.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	global_position += Vector2.from_angle(global_rotation) * speed
	
func _on_area_entered(area: Area2D) -> void:
	onHit(area)

func _on_body_entered(body: Node2D) -> void:
	onHit(body)

func onHit(area : Node2D) -> void:
	#var damageTarget := _resolve_damage_target(body)
	if area.has_method("onDamage"):
		if (attack.pierces):
			area.onDamage(attack)
		else:
			if area.onDamage(attack):
				queue_free()

func _resolve_damage_target(target: Node) -> Node2D:
	var current := target

	while current != null:
		if current is Node2D and current.has_method("onDamage"):
			return current as Node2D
		current = current.get_parent()
	return null

#func onHit(body:Node2D):
	#print("Generic projectile collision by " + body.name + " from " + self.name)
