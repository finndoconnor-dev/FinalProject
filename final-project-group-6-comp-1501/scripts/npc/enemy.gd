extends CharacterBody2D


@export var player= Node2D
@export var speed = 75.0
@export var maxHealthPoints = 100
@export var immunityTime = 0.005

@onready var animatedSprite = $AnimatedSprite2D
@onready var navAgent := $NavigationAgent2D as NavigationAgent2D
@onready var hpBar = $HealthBar
@onready var invincibilityTimer = $InvinicbilityFrames

var canMove=true
var hitpoints : float

func _ready() -> void:
	invincibilityTimer.one_shot = true
	hitpoints = maxHealthPoints
	hpBar.max_value = maxHealthPoints
	hpBar.min_value = 0
	hpBar.value = hitpoints
	updateHealthbar()
	
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
	
#Acts as range detection will cause the enemy to stop and eventually start shooting at the player
func _on_area_2d_body_entered(body: Node2D) -> void:
	if(body==player):
		canMove=false

func _on_area_2d_body_exited(body: Node2D) -> void:
	if(body==player):
		canMove=true

func onDamage(incDamage : Attack) -> void:
	print(self.name + " took damage.")
	if !invincibilityTimer.is_stopped(): return
	if incDamage.triggerInvulnerability:invincibilityTimer.start(immunityTime)
	hitpoints -= incDamage.damage
	updateHealthbar()
	
func updateHealthbar() -> void:
	hpBar.value = hitpoints

"
#Enemy dropping collectibles would likely go in here
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is Bullet:
		queue_free()
		area.queue_free()
		
"
