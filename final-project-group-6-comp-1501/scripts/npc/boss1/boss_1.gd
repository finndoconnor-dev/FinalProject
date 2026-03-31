extends CharacterBody2D

enum State {
	IDLE,
	ATTACKING
}

signal stateChanged(previous_state: State, new_state: State)
signal setLeftHandState(state: State)
signal setRightHandState(state: State)

@export var maxHP := 10000
@export var idle_duration := 2.0
@export var attack_duration := 8.0

@onready var leftHand: CharacterBody2D = $LeftHand
@onready var rightHand: CharacterBody2D = $RightHand

var bossState: State = State.IDLE
var state_timer := 0.0


func _ready() -> void:
	randomize()
	_connect_hands()
	_apply_state(bossState, bossState)


func _physics_process(delta: float) -> void:
	state_timer += delta

	match bossState:
		State.IDLE:
			idle(delta)
		State.ATTACKING:
			isAttacking(delta)


func idle(_delta: float) -> void:
	if state_timer >= idle_duration:
		setState(State.ATTACKING)


func isAttacking(_delta: float) -> void:
	if state_timer >= attack_duration:
		setState(State.IDLE)


func setState(new_state: State) -> void:
	if new_state == bossState:
		return

	var previous_state := bossState
	bossState = new_state
	_apply_state(previous_state, bossState)


func enterState(newState: State) -> void:
	setState(newState)


func _apply_state(previous_state: State, new_state: State) -> void:
	state_timer = 0.0

	setLeftHandState.emit(new_state)
	setRightHandState.emit(new_state)

	if is_instance_valid(leftHand) and leftHand.has_method("set_active"):
		leftHand.set_active(new_state == State.ATTACKING)
	if is_instance_valid(rightHand) and rightHand.has_method("set_active"):
		rightHand.set_active(new_state == State.ATTACKING)

	stateChanged.emit(previous_state, new_state)


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
