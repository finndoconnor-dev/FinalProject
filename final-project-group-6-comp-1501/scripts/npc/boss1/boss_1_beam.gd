extends Node2D

class_name Boss1BeamFSM

enum BeamState {
	INACTIVE,
	COOLDOWN,
	WINDUP,
	FIRING,
	BARRAGE
}

signal activeChanged(isActive: bool)

@export var bodyBeamCooldownMin := 1
@export var bodyBeamCooldownMax := 2
@export var bodyBeamWindup := 1.2
@export var bodyBeamLinger := 1.4
@export var bodyBeamDamage := 20.0
@export var projectileScene: PackedScene = preload("res://scenes/final/npc/boss1/boss_shot.tscn")
@export var barrageProjectileCount := 25
@export var barrageProjectileInterval := 0.08
@export var barrageProjectileSpread := 0.5
@export var barrageProjectileSpeedVariance := 0.2
@export var barrageSpawnOffset := 32.0
@export_range(0.0, 1.0) var barrageAttackChance := 0.5
@export var animationName := "BodyBeam"
@export var resetAnimationName := "RESET"

@onready var beamHitBox: Area2D = $BeamHitBox
@onready var beamHitBoxShape: CollisionShape2D = $BeamHitBox/CollisionShape2D
@onready var animationPlayer: AnimationPlayer = $"../../AnimationPlayer"
@onready var leftHand: Node = $"../../LeftHand"
@onready var rightHand: Node = $"../../RightHand"

var active := false
var beamState := BeamState.INACTIVE
var beamTimer := 0.0
var beamCooldown := 0.0
var beamLockedRotation := 0.0
var beamAttack := Attack.new()
var beamHitTargets: Array[Node2D] = []
var barrageShotsRemaining := 0


func _ready() -> void:
	beamAttack.damage = bodyBeamDamage
	beamAttack.damagesPlayer = true
	beamAttack.damagesNPC = false
	beamAttack.triggerInvulnerability = true
	_set_beam_hitbox_enabled(false)
	_reset_beam_visual()
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	if not active:
		return

	match beamState:
		BeamState.INACTIVE:
			_start_beam_cooldown()
		BeamState.COOLDOWN:
			beamCooldown -= delta
			if beamCooldown <= 0.0:
				if _can_use_barrage() and randf() <= barrageAttackChance:
					_start_barrage_attack()
				else:
					_start_beam_windup()
		BeamState.WINDUP:
			beamTimer -= delta
			global_rotation = beamLockedRotation
			if beamTimer <= 0.0:
				_start_beam_firing()
		BeamState.FIRING:
			beamTimer -= delta
			global_rotation = beamLockedRotation
			_damage_players_in_beam()
			if beamTimer <= 0.0:
				_finish_beam_attack()
		BeamState.BARRAGE:
			_update_barrage(delta)


func set_active(value: bool) -> void:
	if active == value:
		return

	active = value
	activeChanged.emit(active)

	if active:
		_start_beam_cooldown()
	else:
		_cancel_beam_attack()


func is_INACTIVE() -> bool:
	return beamState == BeamState.INACTIVE

func is_COOLDOWN() -> bool:
	return beamState == BeamState.COOLDOWN


func _start_beam_cooldown() -> void:
	beamState = BeamState.COOLDOWN
	beamCooldown = randf_range(bodyBeamCooldownMin, bodyBeamCooldownMax)
	barrageShotsRemaining = 0
	beamHitTargets.clear()
	_set_beam_hitbox_enabled(false)
	_reset_beam_visual()


func _start_beam_windup() -> void:
	var player := _get_player()
	var targetPosition := global_position + Vector2.RIGHT * 100.0

	if is_instance_valid(player):
		targetPosition = player.global_position

	beamLockedRotation = global_position.angle_to_point(targetPosition)
	global_rotation = beamLockedRotation
	beamState = BeamState.WINDUP
	beamTimer = bodyBeamWindup
	beamHitTargets.clear()

	var animationSpeed := _get_body_beam_animation_speed()
	if animationPlayer != null and animationPlayer.has_animation(animationName):
		animationPlayer.play(animationName, -1.0, animationSpeed)


func _start_beam_firing() -> void:
	beamState = BeamState.FIRING
	beamTimer = bodyBeamLinger
	beamHitTargets.clear()
	global_rotation = beamLockedRotation
	_set_beam_hitbox_enabled(true)
	_damage_players_in_beam()


func _finish_beam_attack() -> void:
	_set_beam_hitbox_enabled(false)
	_reset_beam_visual()
	_start_beam_cooldown()


func _start_barrage_attack() -> void:
	beamState = BeamState.BARRAGE
	beamTimer = 0.0
	barrageShotsRemaining = barrageProjectileCount
	beamHitTargets.clear()
	_set_beam_hitbox_enabled(false)
	_reset_beam_visual()


func _cancel_beam_attack() -> void:
	beamState = BeamState.INACTIVE
	beamTimer = 0.0
	beamCooldown = 0.0
	barrageShotsRemaining = 0
	beamHitTargets.clear()
	_set_beam_hitbox_enabled(false)
	_reset_beam_visual()


func _set_beam_hitbox_enabled(enabled: bool) -> void:
	if is_instance_valid(beamHitBoxShape):
		beamHitBoxShape.set_deferred("disabled", not enabled)
	if is_instance_valid(beamHitBox):
		beamHitBox.set_deferred("monitoring", enabled)
		beamHitBox.set_deferred("monitorable", enabled)


func _damage_players_in_beam() -> void:
	if not is_instance_valid(beamHitBox):
		return

	for body in beamHitBox.get_overlapping_bodies():
		var target := body as Node2D
		if target == null:
			continue
		if beamHitTargets.has(target):
			continue
		if not target.has_method("onDamage"):
			continue

		var didTakeDamage = target.onDamage(beamAttack)
		if didTakeDamage:
			beamHitTargets.append(target)


func _update_barrage(delta: float) -> void:
	beamTimer -= delta

	if beamTimer > 0.0:
		return

	if barrageShotsRemaining <= 0:
		_start_beam_cooldown()
		return

	if _fire_barrage_projectile():
		barrageShotsRemaining -= 1

	beamTimer = barrageProjectileInterval


func _get_body_beam_animation_speed() -> float:
	var totalAttackTime := bodyBeamWindup + bodyBeamLinger
	if totalAttackTime <= 0.0:
		return 1.0
	if animationPlayer == null or not animationPlayer.has_animation(animationName):
		return 1.0

	var animationLength := animationPlayer.get_animation(animationName).length
	if animationLength <= 0.0:
		return 1.0

	return animationLength / totalAttackTime


func _reset_beam_visual() -> void:
	if animationPlayer != null and animationPlayer.has_animation(resetAnimationName):
		animationPlayer.play(resetAnimationName)


func _can_use_barrage() -> bool:
	return _is_hand_broken(leftHand) and _is_hand_broken(rightHand)


func _is_hand_broken(hand: Node) -> bool:
	return is_instance_valid(hand) and hand.get("isDead") == true


func _fire_barrage_projectile() -> bool:
	var player := _get_player()
	if projectileScene == null or not is_instance_valid(player):
		return false

	var projectileInstance := projectileScene.instantiate() as Node2D
	if projectileInstance == null:
		return false

	var spawnParent := get_tree().current_scene
	if spawnParent == null:
		spawnParent = get_tree().root

	spawnParent.add_child(projectileInstance)
	projectileInstance.global_rotation = global_position.angle_to_point(player.global_position)
	projectileInstance.global_rotation += randf_range(-barrageProjectileSpread, barrageProjectileSpread)
	projectileInstance.global_position = global_position + Vector2.from_angle(projectileInstance.global_rotation) * barrageSpawnOffset
	projectileInstance.speed += randf_range(-barrageProjectileSpeedVariance, barrageProjectileSpeedVariance)
	return true


func _get_player() -> Node2D:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	return players[0] as Node2D
