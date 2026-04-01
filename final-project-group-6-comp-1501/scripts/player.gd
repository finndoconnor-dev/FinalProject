extends CharacterBody2D

@export var speed = 20
@export var gunController : Node2D
@export var maxHP = 100
@export var invincibilityTime = 0.14 #how long player is immune to damage after being hit.

@onready var invincTimer = $InvincFrames

var isPlayer = true
var lastDirection = "Down" #Directions need capitalization
var hitPoints = maxHP
signal useItem
signal tookDamage

func _ready() -> void:
	invincTimer.one_shot = true
	tookDamage.emit(hitPoints) #inits healthbar
	add_to_group("player")
	upgradeController.setPlayer(self)

func _process(_delta:float) -> void:
	self.setAnimation()
	
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
	if (inc.damagesPlayer and invincTimer.is_stopped()):
		hitPoints -= inc.damage
		if (hitPoints <= 0):
			print("Player died... That isn't programmed yet...")
		invincTimer.start(invincibilityTime)
		tookDamage.emit()
		return true
	return false

func _on_base_layers_map_changed() -> void:
	self.global_position.x=272
	self.global_position.y=447
