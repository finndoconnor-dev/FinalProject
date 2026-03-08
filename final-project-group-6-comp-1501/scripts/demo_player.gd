extends CharacterBody2D

@export var speed = 20
@export var gunController : Node2D

var lastDirection = "Down" #Directions need capitalization
signal useItem

func _ready() -> void:
	pass

func _process(delta:float) -> void:
	self.setAnimation()
	
func _physics_process(delta: float) -> void:
	self.getInput()
	self.move_and_slide()

func setAnimation() -> void:
	if (self.velocity != Vector2.ZERO):
		$AnimatedSprite2D.play("walk"+getMovementDirection())
	else:
		$AnimatedSprite2D.play("idle"+lastDirection)

func getInput():
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
	

	
