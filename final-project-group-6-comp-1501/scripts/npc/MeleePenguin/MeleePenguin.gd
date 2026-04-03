extends CharacterBody2D
class_name penguin

static var _last_global_hurt_sound_time := -INF

@export var speed = 50
@export var maxHealthPoints = 100
@export var immunityTime = 0.00
@export var min_path_update_interval: float = 0.22
@export var min_damage_tick_interval: float = 0.12
@export var repath_player_move_threshold: float = 24.0
@export var repath_self_move_threshold: float = 32.0
@export var direct_chase_distance: float = 96.0
@export var hurt_sound_cooldown: float = 0.08
@export var hurt_sound_pitch_min: float = 0.95
@export var hurt_sound_pitch_max: float = 1.05

@onready var animatedSprite = $AnimatedSprite2D
@onready var navAgent := $NavigationAgent2D as NavigationAgent2D
@onready var pathfindingTimer: Timer = $PathfindingTimer
@onready var hpBar = $HealthBar
@onready var invincibilityTimer = $InvinicbilityFrames
@onready var damageTimer : Timer = $DamageTimer
@onready var attackRadius : Area2D = $AttackRadius
@onready var hurtSound: AudioStreamPlayer2D = $HurtSound

var canMove=true
var hitpoints : float
var meleeAttack : Attack = Attack.new()
var player: Node2D
var playerInAttackRadius := false
var isDead := false
var hasLastTargetPosition := false
var lastTargetPosition := Vector2.ZERO
var hasLastPathOrigin := false
var lastPathOrigin := Vector2.ZERO

signal npcHasDied


func _ready() -> void:
	invincibilityTimer.one_shot = true
	pathfindingTimer.wait_time = max(pathfindingTimer.wait_time, min_path_update_interval)
	damageTimer.wait_time = max(damageTimer.wait_time, min_damage_tick_interval)
	pathfindingTimer.start(pathfindingTimer.wait_time + randf() * 0.08)
	damageTimer.start(damageTimer.wait_time + randf() * 0.05)
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

func _physics_process(delta: float) -> void:
	if isDead:
		return
	#Controls Enemy movement 
	#Pathfinding using a navigation agent and the navigation tiles in the tileset currently doesn't work for multilayered tilemaps
	var direction := Vector2.ZERO
	if player != null:
		var distanceToPlayerSquared := global_position.distance_squared_to(player.global_position)
		if distanceToPlayerSquared <= direct_chase_distance * direct_chase_distance:
			direction = global_position.direction_to(player.global_position)
		elif !navAgent.is_navigation_finished():
			direction = global_position.direction_to(navAgent.get_next_path_position())
	if(canMove):
		velocity = direction*speed
		move_and_slide()
	
	if player.global_position.x<self.global_position.x:
		self.scale.x=-1
	else:
		self.scale.x=1
	
#updates the path based on the timer if it becomes to resource intensive then we can limit the timer
func makepath() -> void:
	if player == null:
		player = getPlayer()
	if player != null:
		var targetPosition := player.global_position
		var shouldRepath := !hasLastTargetPosition
		if !shouldRepath and lastTargetPosition.distance_squared_to(targetPosition) >= repath_player_move_threshold * repath_player_move_threshold:
			shouldRepath = true
		if !shouldRepath and (!hasLastPathOrigin or lastPathOrigin.distance_squared_to(global_position) >= repath_self_move_threshold * repath_self_move_threshold):
			shouldRepath = true
		if shouldRepath:
			hasLastTargetPosition = true
			hasLastPathOrigin = true
			lastTargetPosition = targetPosition
			lastPathOrigin = global_position
			navAgent.target_position = targetPosition
	
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
	play_hurt_sound()
	updateHealthbar()
	if hitpoints <= 0:
		die()
	return true
	
func updateHealthbar() -> void:
	hpBar.value = hitpoints

func play_hurt_sound() -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if now - _last_global_hurt_sound_time < hurt_sound_cooldown:
		return

	_last_global_hurt_sound_time = now
	hurtSound.pitch_scale = randf_range(hurt_sound_pitch_min, hurt_sound_pitch_max)
	hurtSound.play()

func getPlayer() -> Node2D:
	var p := get_tree().get_first_node_in_group("player") as Node2D
	return p

func attackInRadius()-> void:
	if !playerInAttackRadius or player == null or !is_instance_valid(player):
		return
	if player.has_method("onDamage"):
		player.onDamage(meleeAttack)


func onDamageTimer() -> void:
	attackInRadius()

func onAttackRadiusEntered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		playerInAttackRadius = true

func onAttackRadiusExited(body: Node2D) -> void:
	if body.is_in_group("player"):
		playerInAttackRadius = false

func die() -> void:
	if isDead:
		return
	isDead = true
	npcHasDied.emit()
	queue_free()
