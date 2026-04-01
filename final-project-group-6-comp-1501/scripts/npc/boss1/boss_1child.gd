extends Node2D

class_name Boss1ChildFSM

enum HandState {
	INACTIVE,
	HOVER,
	PROJECTILE,
	TRACKING,
	DASH,
	RETURNING,
	BROKEN
}

signal activeChanged(isActive: bool)
signal attackStarted(state: HandState)

@export var projectileScene: PackedScene = preload("res://scenes/final/npc/boss1/boss_shot.tscn")
@export var hoverHeight := 25
@export var hoverSpeed := 3
@export var returnSpeed := 140
@export var trackPositionOffsetLeft : Vector2 = Vector2(0,150)
@export var trackPositionOffsetRight: Vector2 = Vector2(-150,0)
@export var trackSpeed := 240.0
@export var dashSpeed := 140
@export var trackDuration := 3
@export var dashDuration := 3
@export var projectileCount := 7
@export var projectileInterval := 0.22
@export var projectileSpread := 0.22
@export var projectileSpeedVariance := 0.2
@export var attackCooldownMin := 1.0
@export var attackCooldownMax := 2.4
@export var brokenAttackCooldownMin := 2.0
@export var brokenAttackCooldownMax := 5.0
@export var dashDamage := 3.0
@export var maxHP : float = 1000.0
@export var immunityFrames := 0.01

@onready var handSprite: AnimatedSprite2D = $HandAlive
@onready var handSpriteDead : Sprite2D = $HandDead
@onready var hitBox: Area2D = $Hitbox
@onready var invincTimer: Timer = $ImmunityFrames
@onready var healthBar := $HealthBar

var active := false
var isDead := false
var handState := HandState.INACTIVE
var bossBody: Node2D
var player: Node2D
var restOffset := Vector2.ZERO
var hoverTime := 0.0
var stateTimer := 0.0
var attackCooldown := 0.0
var shotsRemaining := 0
var projectileTimer := 0.0
var dashDirection := Vector2.ZERO
var dashAttack : Attack = Attack.new()
var hitpoints : float


func _ready() -> void:
	bossBody = get_parent() as Node2D
	hitpoints = maxHP
	dashAttack.damage = dashDamage
	dashAttack.damagesNPC = false
	dashAttack.damagesPlayer = true
	restOffset = position
	invincTimer.one_shot = true
	healthBar.max_value = maxHP
	healthBar.min_value = 0
	healthBar.value = hitpoints
	handSprite.play("default")
	if is_instance_valid(hitBox) and not hitBox.body_entered.is_connected(_on_body_entered):
		hitBox.body_entered.connect(_on_body_entered)
	handSpriteDead.hide()
	set_physics_process(true)
	transition_to(HandState.INACTIVE)


func _physics_process(delta: float) -> void:
	hoverTime += delta
	stateTimer += delta
	player = _get_player()

	match handState:
		HandState.INACTIVE:
			_move_to_rest(delta)
		HandState.HOVER:
			_update_hover(delta)
		HandState.PROJECTILE:
			_update_projectile_attack(delta)
		HandState.TRACKING:
			_update_tracking(delta)
		HandState.DASH:
			_update_dash(delta)
		HandState.RETURNING:
			_update_returning(delta)
		HandState.BROKEN:
			_update_broken(delta)


func set_active(value: bool) -> void:
	if isDead:
		return

	if active == value:
		return

	active = value
	activeChanged.emit(active)

	if active:
		transition_to(HandState.HOVER)
	else:
		transition_to(HandState.INACTIVE)


func is_active() -> bool:
	return active


func onDamage(inc: Attack) -> bool:
	if isDead:
		return false
	if not inc.damagesNPC:
		return false
	if not invincTimer.is_stopped():
		return false

	invincTimer.start(immunityFrames)
	hitpoints -= inc.damage

	healthBar.value = hitpoints

	if hitpoints <= 0.0:
		onDeath()

	return true


func onDeath() -> void:
	if isDead:
		return

	isDead = true
	active = false
	if is_instance_valid(hitBox):
		hitBox.monitoring = false
		hitBox.monitorable = false
	handSprite.hide()
	handSpriteDead.show()
	transition_to(HandState.BROKEN)


func on_body_idle() -> void:
	set_active(false)


func on_body_attacking() -> void:
	set_active(true)


func transition_to(newState: HandState) -> void:
	handState = newState
	stateTimer = 0.0

	match handState:
		HandState.INACTIVE:
			attackCooldown = 0.0
			shotsRemaining = 0
			projectileTimer = 0.0
			dashDirection = Vector2.ZERO
		HandState.HOVER:
			attackCooldown = randf_range(attackCooldownMin, attackCooldownMax)
		HandState.PROJECTILE:
			shotsRemaining = projectileCount
			projectileTimer = 0.0
			attackStarted.emit(handState)
		HandState.TRACKING:
			attackStarted.emit(handState)
		HandState.DASH:
			attackStarted.emit(handState)
		HandState.RETURNING:
			pass
		HandState.BROKEN:
			shotsRemaining = 0
			projectileTimer = 0.0
			dashDirection = Vector2.ZERO
			attackCooldown = randf_range(brokenAttackCooldownMin, brokenAttackCooldownMax)


func _update_hover(delta: float) -> void:
	_move_to_rest(delta)
	attackCooldown -= delta

	if attackCooldown > 0.0:
		return

	if randf() < 0.5:
		transition_to(HandState.PROJECTILE)
	else:
		transition_to(HandState.TRACKING)


func _update_projectile_attack(delta: float) -> void:
	if not is_instance_valid(player):
		transition_to(HandState.RETURNING)
		return

	_move_to_rest(delta)
	projectileTimer -= delta

	if projectileTimer > 0.0:
		return

	if shotsRemaining <= 0:
		transition_to(HandState.HOVER)
		return

	_fire_projectile()
	shotsRemaining -= 1
	projectileTimer = projectileInterval

	if shotsRemaining <= 0:
		attackCooldown = randf_range(attackCooldownMin, attackCooldownMax)


func _update_tracking(delta: float) -> void:
	if not is_instance_valid(player):
		transition_to(HandState.RETURNING)
		return

	var desiredPosition := player.global_position + _get_hand_side_offset()
	global_position = global_position.move_toward(desiredPosition, trackSpeed * delta)

	if stateTimer >= trackDuration:
		dashDirection = global_position.direction_to(player.global_position)
		if dashDirection == Vector2.ZERO:
			dashDirection = Vector2.RIGHT.rotated(randf() * TAU)
		transition_to(HandState.DASH)


func _update_dash(delta: float) -> void:
	global_position += dashDirection * dashSpeed * delta

	if stateTimer >= dashDuration:
		transition_to(HandState.RETURNING)


func _update_returning(delta: float) -> void:
	var reachedRest := _move_to_rest(delta)
	if reachedRest:
		if active:
			transition_to(HandState.HOVER)
		else:
			transition_to(HandState.INACTIVE)


func _update_broken(delta: float) -> void:
	attackCooldown -= delta

	if attackCooldown > 0.0:
		return

	if not is_instance_valid(player):
		attackCooldown = randf_range(brokenAttackCooldownMin, brokenAttackCooldownMax)
		return

	for _shot in projectileCount:
		_fire_projectile()

	attackCooldown = randf_range(brokenAttackCooldownMin, brokenAttackCooldownMax)


func _move_to_rest(delta: float) -> bool:
	var restPosition := _get_rest_global_position()
	global_position = global_position.move_toward(restPosition, returnSpeed * delta)
	return global_position.distance_to(restPosition) <= 4.0


func _get_rest_global_position() -> Vector2:
	var hoverOffset := Vector2(0.0, sin(hoverTime * hoverSpeed) * hoverHeight)

	if bossBody == null:
		return global_position + hoverOffset

	return bossBody.global_position + restOffset + hoverOffset


func _get_player() -> Node2D:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	return players[0] as Node2D


func _get_hand_side_offset() -> Vector2:
	if restOffset.x < 0.0:
		#return Vector2(-90.0, -40.0)
		return trackPositionOffsetRight
	return trackPositionOffsetLeft


func _fire_projectile() -> void:
	if projectileScene == null or not is_instance_valid(player):
		return

	var projectileInstance := projectileScene.instantiate() as Node2D
	if projectileInstance == null:
		return

	var spawnParent := get_tree().current_scene
	if spawnParent == null:
		spawnParent = get_tree().root

	spawnParent.add_child(projectileInstance)
	projectileInstance.global_position = global_position
	projectileInstance.global_rotation = global_position.angle_to_point(player.global_position)
	projectileInstance.global_rotation += randf_range(-projectileSpread, projectileSpread)
	projectileInstance.speed += randf_range(-projectileSpeedVariance, projectileSpeedVariance)


func _on_body_entered(body) -> void:
	if handState != HandState.DASH:
		return

	if body.is_in_group("player") and body.has_method("onDamage"):
		body.onDamage(dashAttack)
