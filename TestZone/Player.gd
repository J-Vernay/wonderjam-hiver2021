extends KinematicBody2D

export var controlMode = 1 # Can be 1 or 2 if player 1 or 2

const VECTOR_UP = Vector2(0, -1)
const MAXSPEED = 300
const FRICTION = 0.2
const ACCELERATION = 40
const AIRCONTROLRATIO = 0.1
const GRAVITY = 600
const JUMPFORCE = 300

var velocity : Vector2

func _ready():
	velocity = Vector2(0, 0)


func _physics_process(delta):
	var right = Input.is_action_pressed(getMyInput("Right"))
	var left = Input.is_action_pressed(getMyInput("Left"))
	var up = Input.is_action_pressed(getMyInput("Up"))
	var jump = Input.is_action_just_pressed(getMyInput("Up"))
	var down = Input.is_action_pressed(getMyInput("Down"))
	if(right != left):
		if(right):
			velocity.x = clamp(velocity.x + ACCELERATION, -MAXSPEED, MAXSPEED)
		else:
			velocity.x = clamp(velocity.x - ACCELERATION, -MAXSPEED, MAXSPEED)
	else:
		velocity.x = lerp(velocity.x, 0, FRICTION)
	if(jump && is_on_floor()):
		velocity.y = -JUMPFORCE
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, VECTOR_UP)





func getMyInput(name : String):
	return name + str(controlMode)
