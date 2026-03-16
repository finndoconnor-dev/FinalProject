extends CharacterBody2D
class_name baseEnemy

@export var player= Node2D
@export var speed = 75.0
@export var maxHealthPoints = 100
@export var immunityTime = 0.00
@export var gun : PackedScene

@onready var animatedSprite = $AnimatedSprite2D
@onready var navAgent := $NavigationAgent2D as NavigationAgent2D
@onready var hpBar = $HealthBar
@onready var invincibilityTimer = $InvinicbilityFrames
@onready var shootTimer : Timer = $ShootTimer

var canMove=true
var hitpoints : float
var gunNode


func _ready() -> void:
	invincibilityTimer.one_shot = true
	hitpoints = maxHealthPoints
	hpBar.max_value = maxHealthPoints
	hpBar.min_value = 0
	hpBar.value = hitpoints
	updateHealthbar()
	
	gunNode = gun.instantiate()
	add_child(gunNode)
	
	# Aim gun at player instead of mouse
	var gunRotate = gunNode.get_node_or_null("GunRotate")
	if gunRotate:
		gunRotate.useMouse = false
		gunRotate.target = player
	
#For animations
func _process(delta: float) -> void:
	animatedSprite.play("run")

func _physics_process(delta: float) -> void:
	#Controls Enemy movement 
	#Pathfinding using a navigation agent and the navigation tiles in the tileset currently doesn't work for multilayered tilemaps
	var direction = to_local(navAgent.get_next_path_position()).normalized()
	if(canMove):
		velocity = direction*speed
		move_and_slide()
	if(hitpoints <= 0): queue_free()
	
#updates the path based on the timer if it becomes to resource intensive then we can limit the timer
func makepath() -> void:
	navAgent.target_position=player.global_position
	
func _on_timer_timeout() -> void:
	makepath()
	
func takeStopAction() -> void:
	pass

func takeMoveAction() -> void:
	pass
	
#Acts as range detection will cause the enemy to stop and eventually start shooting at the player
func _on_area_2d_body_entered(body: Node2D) -> void:
	if(body==player):
		takeStopAction()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if(body==player):
		takeMoveAction()

func onDamage(incDamage : Attack) -> void:
	print(self.name + " took damage.")
	if !invincibilityTimer.is_stopped(): return
	if incDamage.triggerInvulnerability:invincibilityTimer.start(immunityTime)
	hitpoints -= incDamage.damage
	updateHealthbar()
	
func updateHealthbar() -> void:
	hpBar.value = hitpoints
