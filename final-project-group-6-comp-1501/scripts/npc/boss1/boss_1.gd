extends CharacterBody2D

enum Phase {
	HANDS_ONLY,
	ONE_HAND_DOWN,
	HANDS_DESTROYED,
	FINAL
}

signal phaseChanged(previousPhase: Phase, newPhase: Phase)

@export var outgoingLevel : PackedScene
@export var maxHP := 10000
@export var immunityFrames := 0.01
@export var finalPhaseAttackCooldown := 1.0

@onready var leftHand: Boss1ChildFSM = $LeftHand
@onready var rightHand: Boss1ChildFSM = $RightHand
@onready var beamFSM: Boss1BeamFSM = $Body/BeamPivotBody
@onready var invincTimer: Timer = $Body/ImmunityFrames
@onready var healthBar: ProgressBar = $Body/HealthBar

var currentPhase: Phase = Phase.HANDS_ONLY
var hitpoints: float


func _ready() -> void:
	hitpoints = maxHP
	healthBar.max_value = maxHP
	healthBar.min_value = 0
	healthBar.value = hitpoints
	healthBar.hide()
	invincTimer.one_shot = true
	randomize()
	_apply_phase(currentPhase, currentPhase)


func _physics_process(_delta: float) -> void:
	_update_phase()


func onDamage(inc: Attack) -> bool:
	if not inc.damagesNPC:
		return false
	if not _is_body_vulnerable():
		return false
	if not invincTimer.is_stopped():
		return false

	invincTimer.start(immunityFrames)
	hitpoints -= inc.damage
	healthBar.value = hitpoints

	if hitpoints <= 0.0:
		onDeath()
	else:
		_update_phase()

	return true


func onDeath() -> void:
	await get_tree().create_timer(2.0).timeout
	var inv = get_tree().get_first_node_in_group("gunslot")
	inv.exportToLevelTransition()
	get_tree().change_scene_to_packed(outgoingLevel)


func _update_phase() -> void:
	var newPhase := _determine_phase()
	if newPhase == currentPhase:
		return

	var previousPhase := currentPhase
	currentPhase = newPhase
	_apply_phase(previousPhase, currentPhase)


func _determine_phase() -> Phase:
	var defeatedHands := _get_defeated_hand_count()

	if defeatedHands <= 0:
		return Phase.HANDS_ONLY
	if defeatedHands == 1:
		return Phase.ONE_HAND_DOWN
	if hitpoints <= maxHP / 2.0:
		return Phase.FINAL
	return Phase.HANDS_DESTROYED


func _apply_phase(previousPhase: Phase, newPhase: Phase) -> void:
	var bodyUnlocked := newPhase >= Phase.HANDS_DESTROYED
	var beamUnlocked := newPhase >= Phase.ONE_HAND_DOWN
	var barrageUnlocked := newPhase >= Phase.HANDS_DESTROYED

	if bodyUnlocked:
		healthBar.show()
	else:
		healthBar.hide()

	if is_instance_valid(leftHand) and not leftHand.isDead:
		leftHand.set_active(true)
	if is_instance_valid(rightHand) and not rightHand.isDead:
		rightHand.set_active(true)

	if is_instance_valid(beamFSM):
		beamFSM.set_attack_permissions(beamUnlocked, barrageUnlocked)
		if newPhase == Phase.FINAL:
			beamFSM.set_attack_cooldown_range(finalPhaseAttackCooldown, finalPhaseAttackCooldown)
		else:
			beamFSM.reset_attack_cooldown_range()
		beamFSM.set_active(beamUnlocked)

	phaseChanged.emit(previousPhase, newPhase)


func _get_defeated_hand_count() -> int:
	var defeatedHands := 0

	if not is_instance_valid(leftHand) or leftHand.isDead:
		defeatedHands += 1
	if not is_instance_valid(rightHand) or rightHand.isDead:
		defeatedHands += 1

	return defeatedHands


func _is_body_vulnerable() -> bool:
	return currentPhase >= Phase.HANDS_DESTROYED
