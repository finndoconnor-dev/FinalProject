extends CharacterBody2D

class_name Boss2FSM

enum State {
	IDLE,
	PROJECTILELEFT,
	PROJECTILERIGHT,
	ROCKETLEFT,
	ROCKETRIGHT
}

signal state_changed(previous_state: State, new_state: State)
signal enraged_state_entered()

@export var nextScreen : PackedScene
@export var regularProjectile : PackedScene
@export var rocketProjectile : PackedScene
@export var maxHP := 10000
@export var immunityFrames := 0.01
@export_range(0.0, 1.0) var enraged_threshold_ratio := 0.5
@export var idle_duration := 1.5
@export var projectile_left_duration := 2
@export var projectile_right_duration := 2
@export var rocket_left_duration := 2
@export var rocket_right_duration := 2
@export var projectile_barrage_count := 70
@export var projectile_barrage_spread := 3.15
@export var projectile_interval := 0.06
@export var projectile_speed_variance := 0.5
@export var rocket_barrage_count := 12
@export var rocket_barrage_spread := 0.35
@export var rocket_interval := 0.2
@export_range(0.0, 1.0) var enraged_interval_multiplier := 0.75
@export var enraged_projectile_count_bonus := 12
@export var enraged_rocket_count_bonus := 4
@export var enraged_projectile_speed_variance_bonus := 0.25
@export var start_state: State = State.IDLE
@export var projectile_spawn_left: Marker2D
@export var projectile_spawn_right: Marker2D
@export var beam_fire_left: Boss2BeamFSM
@export var beam_fire_right: Boss2BeamFSM

@onready var body: AnimatedSprite2D = $Body
@onready var hitbox: CollisionShape2D = $CollisionShape2D
@onready var healthBar: ProgressBar = _resolve_health_bar()

var current_state: State = State.IDLE
var state_timer := 0.0
var player: Node2D
var barrage_shots_remaining := 0
var barrage_timer := 0.0
var hitpoints: float
var invincibility_remaining := 0.0
var isEnraged := false


func _ready() -> void:
	if projectile_spawn_left == null:
		projectile_spawn_left = _resolve_marker("ProjectileSpawnLeft", "Marker2D")
	if projectile_spawn_right == null:
		projectile_spawn_right = _resolve_marker("ProjectileSpawnRight", "Marker2D2")
	if beam_fire_left == null:
		beam_fire_left = _resolve_beam_fsm("BeamFireLeft", "BeamFireLeft2")
	if beam_fire_right == null:
		beam_fire_right = _resolve_beam_fsm("BeamFireRight", "BeamFireRight")

	hitpoints = maxHP
	if is_instance_valid(healthBar):
		healthBar.max_value = maxHP
		healthBar.min_value = 0
		healthBar.value = hitpoints
		healthBar.hide()
	randomize()
	transition_to(start_state)


func _physics_process(delta: float) -> void:
	state_timer += delta
	invincibility_remaining = maxf(invincibility_remaining - delta, 0.0)
	player = _get_player()

	match current_state:
		State.IDLE:
			_update_idle(delta)
		State.PROJECTILELEFT:
			_update_projectile_left(delta)
		State.PROJECTILERIGHT:
			_update_projectile_right(delta)
		State.ROCKETLEFT:
			_update_rocket_left(delta)
		State.ROCKETRIGHT:
			_update_rocket_right(delta)


func onDamage(inc: Attack) -> bool:
	if not inc.damagesNPC:
		return false
	if invincibility_remaining > 0.0:
		return false

	invincibility_remaining = immunityFrames
	hitpoints -= inc.damage
	if is_instance_valid(healthBar):
		healthBar.value = hitpoints
		healthBar.show()

	if not isEnraged and hitpoints > 0.0 and hitpoints <= maxHP * enraged_threshold_ratio:
		_enter_enraged_state()

	if hitpoints <= 0.0:
		onDeath()

	return true


func onDeath() -> void:
	get_tree().change_scene_to_packed(nextScreen)
	queue_free()


func transition_to(new_state: State) -> void:
	if current_state == new_state and state_timer > 0.0:
		return

	var previous_state := current_state
	_on_exit_state(previous_state)
	current_state = new_state
	state_timer = 0.0
	barrage_shots_remaining = 0
	barrage_timer = 0.0
	_enter_state(new_state)
	state_changed.emit(previous_state, new_state)


func _on_exit_state(previous_state: State) -> void:
	match previous_state:
		State.PROJECTILELEFT:
			_set_beam_enabled(beam_fire_left, false)
		State.PROJECTILERIGHT:
			_set_beam_enabled(beam_fire_right, false)


func _enter_state(new_state: State) -> void:
	match new_state:
		State.IDLE:
			if is_instance_valid(body):
				body.play("default")
		State.PROJECTILELEFT:
			if is_instance_valid(body):
				body.play("shootleft")
			_begin_projectile_left()
		State.PROJECTILERIGHT:
			if is_instance_valid(body):
				body.play("shootright")
			_begin_projectile_right()
		State.ROCKETLEFT:
			if is_instance_valid(body):
				body.play("shootleft")
			_begin_rocket_left()
		State.ROCKETRIGHT:
			if is_instance_valid(body):
				body.play("shootright")
			_begin_rocket_right()


func _update_idle(_delta: float) -> void:
	if state_timer < idle_duration:
		return

	_choose_next_attack()


func _update_projectile_left(delta: float) -> void:
	_update_projectile_barrage(
		delta,
		projectile_spawn_left,
		projectile_left_duration,
		regularProjectile,
		_get_projectile_interval(),
		projectile_barrage_spread,
		_get_projectile_speed_variance(),
		beam_fire_left
	)


func _update_projectile_right(delta: float) -> void:
	_update_projectile_barrage(
		delta,
		projectile_spawn_right,
		projectile_right_duration,
		regularProjectile,
		_get_projectile_interval(),
		projectile_barrage_spread,
		_get_projectile_speed_variance(),
		beam_fire_right
	)


func _update_rocket_left(delta: float) -> void:
	_update_projectile_barrage(
		delta,
		projectile_spawn_left,
		rocket_left_duration,
		rocketProjectile,
		_get_rocket_interval(),
		rocket_barrage_spread
	)


func _update_rocket_right(delta: float) -> void:
	_update_projectile_barrage(
		delta,
		projectile_spawn_right,
		rocket_right_duration,
		rocketProjectile,
		_get_rocket_interval(),
		rocket_barrage_spread
	)


func _update_projectile_barrage(
	delta: float,
	spawn_marker: Marker2D,
	state_duration: float,
	projectile_scene: PackedScene = regularProjectile,
	barrage_interval: float = projectile_interval,
	barrage_spread: float = projectile_barrage_spread,
	speed_variance: float = 0.0,
	active_beam: Boss2BeamFSM = null
) -> void:
	if not is_instance_valid(player):
		transition_to(State.IDLE)
		return

	barrage_timer -= delta
	if barrage_shots_remaining > 0 and barrage_timer <= 0.0:
		_fire_projectile(spawn_marker, projectile_scene, barrage_spread, speed_variance)
		barrage_shots_remaining -= 1
		barrage_timer = barrage_interval

	var beam_finished := true
	if isEnraged and is_instance_valid(active_beam):
		beam_finished = not active_beam.is_busy()

	if barrage_shots_remaining <= 0 and state_timer >= state_duration and beam_finished:
		transition_to(State.IDLE)


func _choose_next_attack() -> void:
	var attack_states: Array[State] = [
		State.PROJECTILELEFT,
		State.PROJECTILERIGHT,
		State.ROCKETLEFT,
		State.ROCKETRIGHT
	]
	var next_state: State = attack_states[randi_range(0, attack_states.size() - 1)]
	if next_state == State.PROJECTILELEFT:
		transition_to(State.PROJECTILELEFT)
	elif next_state == State.PROJECTILERIGHT:
		transition_to(State.PROJECTILERIGHT)
	elif next_state == State.ROCKETLEFT:
		transition_to(State.ROCKETLEFT)
	else:
		transition_to(State.ROCKETRIGHT)


func _begin_projectile_left() -> void:
	barrage_shots_remaining = _get_projectile_barrage_count()
	barrage_timer = 0.0
	_begin_enraged_beam(beam_fire_left)


func _begin_projectile_right() -> void:
	barrage_shots_remaining = _get_projectile_barrage_count()
	barrage_timer = 0.0
	_begin_enraged_beam(beam_fire_right)


func _begin_rocket_left() -> void:
	barrage_shots_remaining = _get_rocket_barrage_count()
	barrage_timer = 0.0


func _begin_rocket_right() -> void:
	barrage_shots_remaining = _get_rocket_barrage_count()
	barrage_timer = 0.0


func _begin_enraged_beam(beam_fsm: Boss2BeamFSM) -> void:
	if not isEnraged:
		return
	_set_beam_enabled(beam_fsm, true)


func _set_beam_enabled(beam_fsm: Boss2BeamFSM, enabled: bool) -> void:
	if not is_instance_valid(beam_fsm):
		return
	beam_fsm.set_attack_enabled(enabled)


func _enter_enraged_state() -> void:
	isEnraged = true
	enraged_state_entered.emit()


func _get_projectile_barrage_count() -> int:
	if isEnraged:
		return projectile_barrage_count + enraged_projectile_count_bonus
	return projectile_barrage_count


func _get_rocket_barrage_count() -> int:
	if isEnraged:
		return rocket_barrage_count + enraged_rocket_count_bonus
	return rocket_barrage_count


func _get_projectile_interval() -> float:
	if isEnraged:
		return projectile_interval * enraged_interval_multiplier
	return projectile_interval


func _get_rocket_interval() -> float:
	if isEnraged:
		return rocket_interval * enraged_interval_multiplier
	return rocket_interval


func _get_projectile_speed_variance() -> float:
	if isEnraged:
		return projectile_speed_variance + enraged_projectile_speed_variance_bonus
	return projectile_speed_variance


func _fire_projectile(spawn_marker: Marker2D, projectile_scene: PackedScene, spread: float, speed_variance: float = 0.0) -> void:
	if projectile_scene == null or not is_instance_valid(spawn_marker) or not is_instance_valid(player):
		return

	var projectile_instance := projectile_scene.instantiate() as Node2D
	if projectile_instance == null:
		return

	var spawn_parent := get_tree().current_scene
	if spawn_parent == null:
		spawn_parent = get_tree().root

	spawn_parent.add_child(projectile_instance)
	projectile_instance.global_position = spawn_marker.global_position
	projectile_instance.global_rotation = spawn_marker.global_position.angle_to_point(player.global_position)
	projectile_instance.global_rotation += randf_range(-spread, spread)
	if "speed" in projectile_instance:
		projectile_instance.speed += randf_range(0, speed_variance)


func _resolve_marker(primary_name: String, fallback_name: String) -> Marker2D:
	var marker := get_node_or_null(primary_name) as Marker2D
	if marker != null:
		return marker
	return get_node_or_null(fallback_name) as Marker2D


func _resolve_health_bar() -> ProgressBar:
	var hp_bar := get_node_or_null("HPBar") as ProgressBar
	if hp_bar != null:
		return hp_bar
	return get_node_or_null("ProgressBar") as ProgressBar


func _resolve_beam_fsm(primary_name: String, fallback_name: String) -> Boss2BeamFSM:
	var beam_fsm := get_node_or_null(primary_name) as Boss2BeamFSM
	if beam_fsm != null:
		return beam_fsm
	return get_node_or_null(fallback_name) as Boss2BeamFSM


func _get_player() -> Node2D: #From HordeSpawner
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	return players[0] as Node2D
