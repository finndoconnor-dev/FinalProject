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
	pass # Replace with function body.

func _on_body_entered(body: Node2D) -> void:
	onHit(body)

func onHit(body : Node2D) -> void:
	if body.has_method("onDamage"):
		if (attack.pierces):
			body.onDamage(attack)
		else:
			if body.onDamage(attack):
				queue_free()

#func onHit(body:Node2D):
	#print("Generic projectile collision by " + body.name + " from " + self.name)
