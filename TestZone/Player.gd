extends KinematicBody2D

export var controlMode = 1 # Can be 1 or 2 if player 1 or 2

var VECTOR_UP = Vector2(0, -1)
var SPEED = 100

func _physics_process(delta):
	var velocity = Vector2(0, 0)
	if(Input.is_action_pressed(getMyInput("Right"))):
		velocity.x += SPEED
	if(Input.is_action_pressed(getMyInput("Left"))):
		velocity.x -= SPEED
	if(Input.is_action_pressed(getMyInput("Down"))):
		velocity.y += SPEED
	if(Input.is_action_pressed(getMyInput("Up"))):
		velocity.y -= SPEED
	velocity = move_and_slide(velocity, VECTOR_UP)
	print(velocity)





func getMyInput(name : String):
	return name + str(controlMode)
