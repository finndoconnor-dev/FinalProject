extends CharacterBody2D

enum State {
	IDLE,
	ATTACKING
}

signal stateChanged(previousState: State, newState: State)
signal setLeftHandState(state: State)
signal setRightHandState(state: State)

@export var maxHP := 10000
@export var immunityFrames = 0.01
@export var idleDuration := 3.0
@export var attackDuration := 16.0

@onready var leftHand: Node2D = $LeftHand
@onready var rightHand: Node2D = $RightHand
@onready var beamFSM: Node = $Body/BeamPivotBody
@onready var invincTimer : Timer = $Body/ImmunityFrames
@onready var healthBar := $Body/HealthBar

var bossState: State = State.IDLE
var stateTimer := 0.0
var hitpoints : float


func _ready() -> void:
	hitpoints = maxHP
	healthBar.max_value = maxHP
	healthBar.min_value = 0
	healthBar.value = hitpoints
	invincTimer.one_shot = true
	randomize()
	_connect_hands()
	_apply_state(bossState, bossState)


func _physics_process(delta: float) -> void:
	stateTimer += delta

	match bossState:
		State.IDLE:
			idle(delta)
		State.ATTACKING:
			isAttacking(delta)


func idle(_delta: float) -> void:
	if stateTimer >= idleDuration:
		setState(State.ATTACKING)


func isAttacking(_delta: float) -> void:
	if stateTimer >= attackDuration and _is_beam_idle():
		setState(State.IDLE)


func setState(newState: State) -> void:
	if newState == bossState:
		return

	var previousState := bossState
	bossState = newState
	_apply_state(previousState, bossState)


func enterState(newState: State) -> void:
	setState(newState)


func _apply_state(previousState: State, newState: State) -> void:
	stateTimer = 0.0

	setLeftHandState.emit(newState)
	setRightHandState.emit(newState)

	var isAttackingState := newState == State.ATTACKING

	if is_instance_valid(leftHand) and leftHand.has_method("set_active"):
		leftHand.set_active(isAttackingState)
	if is_instance_valid(rightHand) and rightHand.has_method("set_active"):
		rightHand.set_active(isAttackingState)
	if is_instance_valid(beamFSM) and beamFSM.has_method("set_active"):
		beamFSM.set_active(isAttackingState)

	stateChanged.emit(previousState, newState)


func _connect_hands() -> void:
	if is_instance_valid(leftHand):
		setLeftHandState.connect(_on_set_left_hand_state)
	if is_instance_valid(rightHand):
		setRightHandState.connect(_on_set_right_hand_state)


func _on_set_left_hand_state(state: State) -> void:
	if is_instance_valid(leftHand) and leftHand.has_method("set_active"):
		leftHand.set_active(state == State.ATTACKING)


func _on_set_right_hand_state(state: State) -> void:
	if is_instance_valid(rightHand) and rightHand.has_method("set_active"):
		rightHand.set_active(state == State.ATTACKING)


func _is_beam_idle() -> bool:
	if not is_instance_valid(beamFSM):
		return false
	return beamFSM.is_INACTIVE() or beamFSM.is_COOLDOWN()


func onDamage(inc :Attack) -> bool:
	if (!inc.damagesNPC): return false
	if (!invincTimer.is_stopped()): return false

	invincTimer.start(immunityFrames)

	var damageTaken = inc.damage

	if (leftHand.hitpoints <= 0 and rightHand.hitpoints <= 0):
		damageTaken *= 5

	hitpoints -= damageTaken

	healthBar.value = hitpoints

	if (hitpoints < maxHP / 2.0):
		phase2()

	if (hitpoints <= 0):
		onDeath()

	return true

func onDeath() -> void:
	queue_free()

func phase2() -> void:
	beamFSM.bodyBeamCooldownMin = 0.5
	beamFSM.bodyBeamCooldownMax = 0.5
	attackDuration = 100
