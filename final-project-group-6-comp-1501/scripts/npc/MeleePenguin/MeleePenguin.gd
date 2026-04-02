extends CharacterBody2D
class_name penguin

@export var speed = 50
@export var maxHealthPoints = 100
@export var immunityTime = 0.00

@onready var animatedSprite = $AnimatedSprite2D
@onready var navAgent := $NavigationAgent2D as NavigationAgent2D
@onready var hpBar = $HealthBar
@onready var invincibilityTimer = $InvinicbilityFrames
@onready var damageTimer : Timer = $DamageTimer
@onready var attackRadius : Area2D = $AttackRadius

var canMove=true
var hitpoints : float
var meleeAttack : Attack = Attack.new()
var player= Node2D

signal npcHasDied


func _ready() -> void:
	invincibilityTimer.one_shot = true
	hitpoints = maxHealthPoints
	hpBar.max_value = maxHealthPoints
	hpBar.min_value = 0
	hpBar.value = hitpoints
	updateHealthbar()
	npcHasDied.connect(upgradeController._on_enemyDied)
	player = getPlayer()
	#init melee attack
	meleeAttack.damagesNPC=false
	meleeAttack.damagesPlayer=true
	meleeAttack.damage = 2
	animatedSprite.play("default")
	if player != null:
		call_deferred("makepath")

#For animations
func _process(delta: float) -> void:
	hpBar.value=hitpoints
	#animatedSprite.play("")

func _physics_process(delta: float) -> void:
	#Controls Enemy movement 
	#Pathfinding using a navigation agent and the navigation tiles in the tileset currently doesn't work for multilayered tilemaps
	var direction := Vector2.ZERO
	if player != null and !navAgent.is_navigation_finished():
		direction = global_position.direction_to(navAgent.get_next_path_position())
	if(canMove):
		velocity = direction*speed
		move_and_slide()
	if(hitpoints <= 0):
		npcHasDied.emit()
		queue_free()
	
#updates the path based on the timer if it becomes to resource intensive then we can limit the timer
func makepath() -> void:
	if player == null:
		player = getPlayer()
	if player != null:
		navAgent.target_position = player.global_position
	
func _on_timer_timeout() -> void:
	makepath()
	
func takeStopAction() -> void:
	pass

func takeMoveAction() -> void:
	pass


func onDamage(incDamage : Attack) -> bool:
	#print(self.name + " took damage.")
	if !invincibilityTimer.is_stopped(): return false
	if incDamage.triggerInvulnerability:invincibilityTimer.start(immunityTime)
	hitpoints -= incDamage.damage
	updateHealthbar()
	return true
	
func updateHealthbar() -> void:
	hpBar.value = hitpoints

func getPlayer() -> Node:
	var p = get_tree().get_first_node_in_group("player")
	if p == null:
		return null
	return p

func attackInRadius()-> void:
	print("Attacking in radius for ",self.name)
	var bodies = attackRadius.get_overlapping_bodies()
	for b in bodies:
		if b.is_in_group("player"):
			b.onDamage(meleeAttack)


func onDamageTimer() -> void:
	attackInRadius()
