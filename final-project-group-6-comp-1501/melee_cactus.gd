extends CharacterBody2D

@export var speed = 50
@export var maxHealthPoints = 100
@export var immunityTime = 0.00

@onready var animatedSprite = $AnimatedSprite2D
@onready var navAgent := $NavigationAgent2D as NavigationAgent2D
@onready var hpBar = $HealthBar
@onready var invincibilityTimer = $InvinicbilityFrames
@onready var damageTimer : Timer = $damageTimer
@onready var attackRadius : Area2D = $attackRadius

var canMove = true
var hitpoints : float
var meleeAttack : Attack = Attack.new()
var player = Node2D

signal npcHasDied

func _ready() -> void:
	invincibilityTimer.one_shot = true
	damageTimer.one_shot = false
	hitpoints = maxHealthPoints
	hpBar.max_value = maxHealthPoints
	hpBar.min_value = 0
	hpBar.value = hitpoints
	updateHealthbar()
	npcHasDied.connect(upgradeController._on_enemyDied)
	player = getPlayer()
	meleeAttack.damagesNPC = false
	meleeAttack.damagesPlayer = true
	meleeAttack.damage = 2
	animatedSprite.play("default")
	if player != null:
		call_deferred("makepath")

func _process(delta: float) -> void:
	hpBar.value = hitpoints

func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO
	if player != null and !navAgent.is_navigation_finished():
		direction = global_position.direction_to(navAgent.get_next_path_position())
	if canMove:
		velocity = direction * speed
		move_and_slide()
	if hitpoints <= 0:
		npcHasDied.emit()
		queue_free()

func makepath() -> void:
	if player == null:
		player = getPlayer()
	if player != null:
		navAgent.target_position = player.global_position

func _on_timer_timeout() -> void:
	makepath()


func _on_attack_radius_body_entered(body: Node2D) -> void:
	print("body entered: ", body.name)
	if body.is_in_group("player"):
		print("player entered attack radius!")
	damageTimer.start()

func _on_damage_timer_timeout() -> void:
	print("damage timer fired!")
	attackInRadius()

func attackInRadius() -> void:
	print("attacking in radius")
	var bodies = attackRadius.get_overlapping_bodies()
	print("bodies found: ", bodies.size())
	for b in bodies:
		if b.is_in_group("player"):
			b.onDamage(meleeAttack)

func onDamage(incDamage : Attack) -> bool:
	if !invincibilityTimer.is_stopped(): return false
	if incDamage.triggerInvulnerability: invincibilityTimer.start(immunityTime)
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

func takeStopAction() -> void:
	pass

func takeMoveAction() -> void:
	pass
