extends CharacterBody2D

@export var speed = 20
@export var gunController : Node2D
@export var maxHP = 100
@export var invincibilityTime = 0.14 #how long player is immune to damage after being hit.
@export var gameOver : PackedScene
const DEFAULT_GAME_OVER_PATH := "res://scenes/final/youlose.tscn"

@onready var invincTimer = $InvincFrames
@onready var upgradeAvailableLabel = $PlayerHUD/Panel/UpgradeAvailable

var isPlayer = true
var lastDirection = "Down" #Directions need capitalization
var hitPoints = maxHP
var isDead := false
signal useItem
signal tookDamage

func _ready() -> void:
	invincTimer.one_shot = true
	tookDamage.emit() #inits healthbar
	add_to_group("player")
	upgradeController.setPlayer(self)
	updateUpgradeAvailability()

func _process(_delta:float) -> void:
	self.setAnimation()
	updateUpgradeAvailability()
	
func _physics_process(delta: float) -> void:
	self.getInput(delta)
	self.move_and_slide()

func setAnimation() -> void:
	if (self.velocity != Vector2.ZERO):
		$AnimatedSprite2D.play("walk"+getMovementDirection())
	else:
		$AnimatedSprite2D.play("idle"+lastDirection)

func getInput(_delta: float):
	var input_vector = Input.get_vector("a","d","w","s")
	self.velocity = input_vector * speed
	if (Input.is_action_just_pressed("left_click")):
		useItem.emit()

func getMovementDirection() -> String:
	if (self.velocity.y < 0 && self.velocity.x == 0): #Up
		lastDirection = "Up"
		return "Up"
	if (self.velocity.y > 0 && self.velocity.x == 0): #down
		lastDirection = "Down"
		return "Down"
	if (self.velocity.y == 0 && self.velocity.x < 0): #left
		lastDirection = "Left"
		return "Left"
	if (self.velocity.y == 0 && self.velocity.x > 0): #right
		lastDirection = "Right"
		return "Right"
	if (self.velocity.y < 0 && self.velocity.x < 0): #upleft
		lastDirection = "UpLeft"
		return "UpLeft"
	if (self.velocity.y < 0 && self.velocity.x > 0): #left
		lastDirection = "UpRight"
		return "UpRight"
	if (self.velocity.y > 0 && self.velocity.x < 0): #downleft
		lastDirection = "DownLeft"
		return "DownLeft"
	if (self.velocity.y > 0 && self.velocity.x > 0): #downright
		lastDirection = "DownRight"
		return "DownRight"
	return "Up"

func onDamage(inc : Attack) -> bool:
	if isDead:
		return false
	if (inc.damagesPlayer and invincTimer.is_stopped()):
		hitPoints -= inc.damage
		if (hitPoints <= 0):
			hitPoints = 0
			onDeath()
			return true
		invincTimer.start(invincibilityTime)
		tookDamage.emit()
		blinkRed()
		$AudioStreamPlayer2D.play()
		return true
	return false

func blinkRed() -> void:
	$AnimatedSprite2D.modulate = Color(1,0,0)
	var tree := get_tree()
	if tree == null:
		return
	await tree.create_timer(invincibilityTime).timeout
	if not is_inside_tree() or isDead:
		return
	$AnimatedSprite2D.modulate = Color(1,1,1)

func onDeath() -> void:
	if isDead:
		return

	isDead = true
	tookDamage.emit()

	var tree := get_tree()
	if tree == null:
		return

	tree.paused = false
	call_deferred("_change_to_game_over")


func _change_to_game_over() -> void:
	var tree := get_tree()
	if tree == null:
		return

	var game_over_path := DEFAULT_GAME_OVER_PATH
	if gameOver != null and gameOver.resource_path != "":
		game_over_path = gameOver.resource_path

	tree.change_scene_to_file(game_over_path)
	

func _on_base_layers_map_changed() -> void:
	self.global_position.x=272
	self.global_position.y=447

func onGamePaused():
	$PlayerHUD.hide()

func updateUpgradeAvailability() -> void:
	#upgradeAvailableLabel.visible = upgradeController.pendingUpgrades > 0
	if (upgradeController.pendingUpgrades > 0):
		upgradeAvailableLabel.text = "You have an upgrade available. Press E to select an upgrade."
	else:
		upgradeAvailableLabel.text = "Next upgrade: %d/%d" % [upgradeController.enemiesKilled,upgradeController.nextUpgrade]
	
