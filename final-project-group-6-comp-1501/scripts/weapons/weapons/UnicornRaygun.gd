extends gun

@export var laserDamage : int = 100
@export var chargeTime : float = 1.2
@export var damageTickRate : float = 0.02
@export var fireAnimationName := "firebeam"
@export var resetAnimationName := "RESET"

@onready var laserHitbox: Area2D = $GunRotate/BeamHitbox
@onready var laserHitboxShape: CollisionShape2D = $GunRotate/BeamHitbox/CollisionShape2D
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

var beamAttack: Attack = Attack.new()
var isFiring := false
var gunRotateWasProcessing := false

func _ready() -> void:
	super()
	shootFunctionPointer = fireLaser
	beamAttack.damage = laserDamage
	beamAttack.damagesNPC = true
	beamAttack.damagesPlayer = false
	beamAttack.triggerInvulnerability = false
	_set_beam_hitbox_enabled(false)
	_reset_beam_visual()

func tryShoot() -> void:
	if isFiring:
		return
	if !cooldownTimer.is_stopped():
		return
	if isEmpty():
		return

	ammoCount -= 1
	gunFired.emit()
	cooldownTimer.start(_get_fire_animation_length())
	shootFunctionPointer.call()

func isEmpty() -> bool:
	if isFiring:
		return false
	return super.isEmpty()

func fireLaser() -> void:
	isFiring = true
	beamAttack.damage = laserDamage
	_lock_rotation()
	_set_beam_hitbox_enabled(false)

	if animationPlayer != null and animationPlayer.has_animation(fireAnimationName):
		animationPlayer.play(fireAnimationName)
	$BeamSound.play()

	await get_tree().create_timer(chargeTime).timeout
	if !is_inside_tree():
		return

	_set_beam_hitbox_enabled(true)
	var remainingDamageTime := maxf(_get_fire_animation_length() - chargeTime, 0.0)
	var elapsed := 0.0
	while elapsed < remainingDamageTime and is_inside_tree():
		_damage_enemies_in_beam()
		await get_tree().create_timer(damageTickRate).timeout
		elapsed += damageTickRate

	_finish_firing()

func _finish_firing() -> void:
	_set_beam_hitbox_enabled(false)
	_reset_beam_visual()
	_unlock_rotation()
	isFiring = false

func _damage_enemies_in_beam() -> void:
	if laserHitbox == null:
		return

	var damagedTargets: Array[Node2D] = []

	for body in laserHitbox.get_overlapping_bodies():
		var target := _resolve_damage_target(body)
		if target == null or damagedTargets.has(target):
			continue
		if target.has_method("onDamage"):
			target.onDamage(beamAttack)
			damagedTargets.append(target)

	for area in laserHitbox.get_overlapping_areas():
		var target := _resolve_damage_target(area)
		if target == null or damagedTargets.has(target):
			continue
		if target.has_method("onDamage"):
			target.onDamage(beamAttack)
			damagedTargets.append(target)

func _resolve_damage_target(target: Node) -> Node2D:
	var current := target

	while current != null:
		if current is Node2D and current.has_method("onDamage"):
			return current as Node2D
		current = current.get_parent()

	return null

func _lock_rotation() -> void:
	if gunRotate == null:
		return
	gunRotateWasProcessing = gunRotate.is_processing()
	gunRotate.set_process(false)

func _unlock_rotation() -> void:
	if gunRotate == null:
		return
	gunRotate.set_process(gunRotateWasProcessing)

func _set_beam_hitbox_enabled(enabled: bool) -> void:
	if laserHitboxShape != null:
		laserHitboxShape.set_deferred("disabled", !enabled)
	if laserHitbox != null:
		laserHitbox.set_deferred("monitoring", enabled)
		laserHitbox.set_deferred("monitorable", enabled)

func _reset_beam_visual() -> void:
	if animationPlayer != null and animationPlayer.has_animation(resetAnimationName):
		animationPlayer.play(resetAnimationName)

func _get_fire_animation_length() -> float:
	if animationPlayer != null and animationPlayer.has_animation(fireAnimationName):
		var animation := animationPlayer.get_animation(fireAnimationName)
		if animation != null and animation.length > 0.0:
			return animation.length
	return maxf(chargeTime, 0.001)

func getUpgrades()->Array:
	var r = []
	var value = -_get_percent_upgrade_amount(reloadSpeed, cooldownUpgradeRange)
	var reload_percent := 0.0
	if reloadSpeed > 0:
		reload_percent = absf(value) / reloadSpeed * 100.0
		r.append({
			"gun": self,
			"stat": "reloadSpeed",
			"upgradeName" : "Steroids",
			"value": value,
			"label":"%s, %.2f%% reduced reload time." % [displayName,reload_percent]
		})
	return r
