extends Node2D

@export var weaponScene: PackedScene
@export var maxDisplaySize := Vector2(32, 32)
@export var preserveWeaponSpriteScale := true

@onready var weaponSprite: Sprite2D = $Sprite2D
@onready var pickupArea: Area2D = $Area2D


func _ready() -> void:
	pickupArea.body_entered.connect(_on_body_entered)
	_refresh_display_sprite()


func _refresh_display_sprite() -> void:
	if weaponScene == null:
		weaponSprite.texture = null
		return

	var weapon_instance := weaponScene.instantiate()
	var source_sprite := weapon_instance.get_node_or_null("GunRotate/Sprite2D") as Sprite2D

	if source_sprite == null or source_sprite.texture == null:
		weaponSprite.texture = null
		weapon_instance.queue_free()
		return

	weaponSprite.texture = source_sprite.texture
	weaponSprite.rotation = 0.0
	weaponSprite.scale = _get_display_scale(source_sprite)
	weapon_instance.queue_free()


func _get_display_scale(source_sprite: Sprite2D) -> Vector2:
	var texture_size := source_sprite.texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return Vector2.ONE

	var base_scale := Vector2.ONE
	if preserveWeaponSpriteScale:
		base_scale = Vector2(absf(source_sprite.scale.x), absf(source_sprite.scale.y))

	var scaled_size := Vector2(texture_size.x * base_scale.x, texture_size.y * base_scale.y)
	if scaled_size.x <= 0.0 or scaled_size.y <= 0.0:
		return base_scale

	var fit_scale: float = min(maxDisplaySize.x / scaled_size.x, maxDisplaySize.y / scaled_size.y)
	var display_scale: Vector2 = base_scale * fit_scale

	return display_scale


func _on_body_entered(body: Node2D) -> void:
	if !body.is_in_group("player"):
		return
	if weaponScene == null:
		return

	var gun_slot: Node = body.gunController
	if gun_slot == null:
		return

	var weapon_instance := weaponScene.instantiate() as gun
	if weapon_instance == null:
		return

	gun_slot.addToInventory(weapon_instance)
	queue_free()
