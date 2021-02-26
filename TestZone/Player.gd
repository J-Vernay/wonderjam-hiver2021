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
var disableImpulse = false

enum direction{
	leftUp = 0, up = 1, upRight = 2, right = 3, downLeft = 4, down = 5, downRight = 6, left = 7, none = 8
}

func _ready():
	velocity = Vector2(0, 0)


func _physics_process(delta):
	var right = Input.is_action_pressed(getMyInput("Right"))
	var left = Input.is_action_pressed(getMyInput("Left"))
	var up = Input.is_action_pressed(getMyInput("Up"))
	var jump = Input.is_action_just_pressed(getMyInput("Jump"))
	var down = Input.is_action_pressed(getMyInput("Down"))
	var attack = Input.is_action_just_pressed(getMyInput("Attack"))
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
	if(velocity.x > 0):
		$AnimatedSprite.flip_h = false
	else:
		$AnimatedSprite.flip_h = true
	velocity = move_and_slide(velocity, VECTOR_UP)
	
	if(disableImpulse):
		$ImpulseZone/CollisionShape2D.disabled = true
		
	if(attack):
		slash(getDirection(up, right, down, left))


func getDirection(up : bool, right : bool, down : bool, left : bool):
	var xdir = int(right) - int(left)
	var ydir = int(up) - int(down)
	var dir = 3*ydir + xdir
	if(dir == 0):
		dir = 1 - 2 * int($AnimatedSprite.flip_h)
	return dir


var slashDirection
func slash(direction):
	disableImpulse = true
	slashDirection = direction
	$ImpulseZone/CollisionShape2D.disabled = false
	#Faut placer la position de la zone maintenant

func getMyInput(name : String):
	return name + str(controlMode)


func _on_ImpulseZone_body_entered(body):
	var impulse = Vector2()
	var FORCE = 500
	match(slashDirection):
		1:
			impulse = Vector2.RIGHT
		2:
			impulse = Vector2(-1, -1)
		3:
			impulse = Vector2.UP
		4:
			impulse = Vector2(1, -1)
		-1:
			impulse = Vector2.LEFT
		-2:
			impulse = Vector2(1, 1)
		-3:
			impulse = Vector2.DOWN
		-4:
			impulse = Vector2(-1, 1)
	
	body.apply_central_impulse(impulse * FORCE)
