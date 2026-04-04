extends Node2D

class_name Boss2BeamFSM

enum BeamState {
	INACTIVE,
	WINDUP,
	FIRING
}

signal attack_started()
signal attack_finished()

@export var beamWindup := 0.5
@export var beamLinger := 0.5
@export var beamDamage := 20.0
@export var offAnimationName := "off"
@export var chargingAnimationName := "charging"
@export var chargedAnimationName := "charged"
@export var fireAnimationName := "fire"

@onready var beamHitBox: Area2D = $BeamHitBox
@onready var beamHitBoxShape: CollisionShape2D = $BeamHitBox/CollisionShape2D
@onready var beamVisual: AnimatedSprite2D = $Beam
@onready var beamAudio: AudioStreamPlayer2D = $BeamFire

var beamState := BeamState.INACTIVE
var beamTimer := 0.0
var beamLockedRotation := 0.0
var beamAttack: Attack = Attack.new()
var beamHitTargets: Array[Node2D] = []
var chargedVisualShown := false


func _ready() -> void:
	beamAttack.damage = beamDamage
	beamAttack.damagesPlayer = true
	beamAttack.damagesNPC = false
	beamAttack.triggerInvulnerability = true
	_set_beam_hitbox_enabled(false)
	_reset_beam_visual()
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	match beamState:
		BeamState.INACTIVE:
			return
		BeamState.WINDUP:
			beamTimer -= delta
			global_rotation = beamLockedRotation
			_update_windup_visual()
			if beamTimer <= 0.0:
				_start_beam_firing()
		BeamState.FIRING:
			beamTimer -= delta
			global_rotation = beamLockedRotation
			_damage_players_in_beam()
			if beamTimer <= 0.0:
				_finish_beam_attack()


func trigger_attack() -> void:
	if beamState != BeamState.INACTIVE:
		return

	var player := _get_player()
	var target_position := global_position + Vector2.RIGHT * 100.0
	if is_instance_valid(player):
		target_position = player.global_position

	beamLockedRotation = global_position.angle_to_point(target_position)
	global_rotation = beamLockedRotation
	beamState = BeamState.WINDUP
	beamTimer = _get_windup_duration()
	beamHitTargets.clear()
	chargedVisualShown = false
	_set_beam_hitbox_enabled(false)
	_play_beam_animation(chargingAnimationName)
	if is_instance_valid(beamAudio):
		beamAudio.play()
	attack_started.emit()


func cancel_attack() -> void:
	beamState = BeamState.INACTIVE
	beamTimer = 0.0
	beamHitTargets.clear()
	chargedVisualShown = false
	_set_beam_hitbox_enabled(false)
	_reset_beam_visual()


func is_busy() -> bool:
	return beamState != BeamState.INACTIVE


func _start_beam_firing() -> void:
	beamState = BeamState.FIRING
	beamTimer = _get_fire_duration()
	beamHitTargets.clear()
	chargedVisualShown = false
	_set_beam_hitbox_enabled(true)
	_play_beam_animation(fireAnimationName)
	_damage_players_in_beam()


func _finish_beam_attack() -> void:
	beamState = BeamState.INACTIVE
	beamTimer = 0.0
	beamHitTargets.clear()
	chargedVisualShown = false
	_set_beam_hitbox_enabled(false)
	_reset_beam_visual()
	attack_finished.emit()


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

		var did_take_damage = target.onDamage(beamAttack)
		if did_take_damage:
			beamHitTargets.append(target)


func _update_windup_visual() -> void:
	if chargedVisualShown:
		return

	if beamTimer <= _get_charged_duration():
		chargedVisualShown = true
		_play_beam_animation(chargedAnimationName)


func _reset_beam_visual() -> void:
	if not is_instance_valid(beamVisual):
		return

	beamVisual.visible = true
	_play_beam_animation(offAnimationName)


func _play_beam_animation(animationName: String) -> void:
	if not is_instance_valid(beamVisual):
		return
	if beamVisual.sprite_frames == null:
		return
	if not beamVisual.sprite_frames.has_animation(animationName):
		return
	if beamVisual.animation == animationName and beamVisual.is_playing():
		return

	beamVisual.play(animationName)


func _get_windup_duration() -> float:
	return maxf(beamWindup, 1.0)


func _get_charged_duration() -> float:
	return maxf(_get_windup_duration() - 1.0, 0.0)


func _get_fire_duration() -> float:
	return 1.0


func _get_player() -> Node2D:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	return players[0] as Node2D
