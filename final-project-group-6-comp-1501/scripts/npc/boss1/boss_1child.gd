extends CharacterBody2D

class_name Boss1ChildFSM

enum HandState {
	INACTIVE,
	HOVER,
	PROJECTILE,
	TRACKING,
	DASH,
	RETURNING
}

signal active_changed(is_active: bool)
signal attack_started(state: HandState)

@export var projectile_scene: PackedScene = preload("res://scenes/final/npc/boss1/boss_shot.tscn")
@export var hover_height := 24.0
@export var hover_speed := 3.0
@export var return_speed := 240.0
@export var track_speed := 240.0
@export var dash_speed := 500
@export var track_duration := 2
@export var dash_duration := 0.9
@export var projectile_count := 7
@export var projectile_interval := 0.22
@export var attack_cooldown_min := 1.0
@export var attack_cooldown_max := 2.4

@onready var hand_sprite: AnimatedSprite2D = $HandAlive

var active := false
var hand_state := HandState.INACTIVE
var boss_body: Node2D
var player: Node2D
var rest_offset := Vector2.ZERO
var hover_time := 0.0
var state_timer := 0.0
var attack_cooldown := 0.0
var shots_remaining := 0
var projectile_timer := 0.0
var dash_direction := Vector2.ZERO


func _ready() -> void:
	boss_body = get_parent() as Node2D
	rest_offset = position
	hand_sprite.play("default")
	set_physics_process(true)
	transition_to(HandState.INACTIVE)


func _physics_process(delta: float) -> void:
	hover_time += delta
	state_timer += delta
	player = _get_player()

	match hand_state:
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


func set_active(value: bool) -> void:
	if active == value:
		return

	active = value
	active_changed.emit(active)

	if active:
		transition_to(HandState.HOVER)
	else:
		transition_to(HandState.INACTIVE)


func is_active() -> bool:
	return active


func on_body_idle() -> void:
	set_active(false)


func on_body_attacking() -> void:
	set_active(true)


func transition_to(new_state: HandState) -> void:
	hand_state = new_state
	state_timer = 0.0

	match hand_state:
		HandState.INACTIVE:
			attack_cooldown = 0.0
			shots_remaining = 0
			projectile_timer = 0.0
			dash_direction = Vector2.ZERO
		HandState.HOVER:
			attack_cooldown = randf_range(attack_cooldown_min, attack_cooldown_max)
		HandState.PROJECTILE:
			shots_remaining = projectile_count
			projectile_timer = 0.0
			attack_started.emit(hand_state)
		HandState.TRACKING:
			attack_started.emit(hand_state)
		HandState.DASH:
			attack_started.emit(hand_state)
		HandState.RETURNING:
			pass


func _update_hover(delta: float) -> void:
	_move_to_rest(delta)
	attack_cooldown -= delta

	if attack_cooldown > 0.0:
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
	projectile_timer -= delta

	if projectile_timer > 0.0:
		return

	if shots_remaining <= 0:
		transition_to(HandState.HOVER)
		return

	_fire_projectile()
	shots_remaining -= 1
	projectile_timer = projectile_interval

	if shots_remaining <= 0:
		attack_cooldown = randf_range(attack_cooldown_min, attack_cooldown_max)


func _update_tracking(delta: float) -> void:
	if not is_instance_valid(player):
		transition_to(HandState.RETURNING)
		return

	var desired_position := player.global_position + _get_hand_side_offset()
	global_position = global_position.move_toward(desired_position, track_speed * delta)

	if state_timer >= track_duration:
		dash_direction = global_position.direction_to(player.global_position)
		if dash_direction == Vector2.ZERO:
			dash_direction = Vector2.RIGHT.rotated(randf() * TAU)
		transition_to(HandState.DASH)


func _update_dash(delta: float) -> void:
	global_position += dash_direction * dash_speed * delta

	if state_timer >= dash_duration:
		transition_to(HandState.RETURNING)


func _update_returning(delta: float) -> void:
	var reached_rest := _move_to_rest(delta)
	if reached_rest:
		if active:
			transition_to(HandState.HOVER)
		else:
			transition_to(HandState.INACTIVE)


func _move_to_rest(delta: float) -> bool:
	var rest_position := _get_rest_global_position()
	global_position = global_position.move_toward(rest_position, return_speed * delta)
	return global_position.distance_to(rest_position) <= 4.0


func _get_rest_global_position() -> Vector2:
	var hover_offset := Vector2(0.0, sin(hover_time * hover_speed) * hover_height)

	if boss_body == null:
		return global_position + hover_offset

	return boss_body.global_position + rest_offset + hover_offset


func _get_player() -> Node2D:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	return players[0] as Node2D


func _get_hand_side_offset() -> Vector2:
	if rest_offset.x < 0.0:
		return Vector2(-90.0, -40.0)
	return Vector2(90.0, -40.0)


func _fire_projectile() -> void:
	if projectile_scene == null or not is_instance_valid(player):
		return

	var projectile_instance := projectile_scene.instantiate() as Node2D
	if projectile_instance == null:
		return

	var spawn_parent := get_tree().current_scene
	if spawn_parent == null:
		spawn_parent = get_tree().root

	spawn_parent.add_child(projectile_instance)
	projectile_instance.global_position = global_position
	projectile_instance.global_rotation = global_position.angle_to_point(player.global_position)
