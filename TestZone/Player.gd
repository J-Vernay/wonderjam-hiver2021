extends KinematicBody2D

export var controlMode = 1 # Can be 1 or 2 if player 1 or 2

const VECTOR_UP = Vector2(0, -1)
const MAXSPEED = 300
const FRICTION = 0.2
const ACCELERATION = 40
const AIRCONTROLRATIO = 0.1
const GRAVITY = 600
const JUMPFORCE = 400

var velocity : Vector2
var disableImpulse = false

enum States{
	Idle, Walk, Jump, Fall, Cast
}


func _ready():
	velocity = Vector2(0, 0)


var state = States.Idle
func _physics_process(delta):
	if(!Engine.editor_hint):
		match(state):
			States.Idle:
				IdleProcess(delta)
			States.Walk:
				WalkProcess(delta)
			States.Jump:
				JumpProcess(delta)
			States.Fall:
				FallProcess(delta)
			States.Cast:
				CastProcess(delta)


func IdleProcess(delta):
	var right = Input.is_action_pressed(getMyInput("Right"))
	var left = Input.is_action_pressed(getMyInput("Left"))
	var up = Input.is_action_pressed(getMyInput("Up"))
	var jump = Input.is_action_pressed(getMyInput("Jump"))
	var down = Input.is_action_pressed(getMyInput("Down"))
	var attack = Input.is_action_just_pressed(getMyInput("Attack"))
	if(right != left):
		setState(States.Walk)
		if(right):
			velocity.x = clamp(velocity.x + ACCELERATION, -MAXSPEED, MAXSPEED)
			$AnimatedSprite.flip_h = false
		else:
			velocity.x = clamp(velocity.x - ACCELERATION, -MAXSPEED, MAXSPEED)
			$AnimatedSprite.flip_h = true
	else:
		velocity.x = lerp(velocity.x, 0, FRICTION)
	if(jump):
		velocity.y = -JUMPFORCE
		setState(States.Jump)
	
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, VECTOR_UP)
	
	if(disableImpulse):
		$ImpulseZone/CollisionShape2D.disabled = true
		
	if(attack):
		slash(getDirection(up, right, down, left))


func WalkProcess(delta):
	var right = Input.is_action_pressed(getMyInput("Right"))
	var left = Input.is_action_pressed(getMyInput("Left"))
	var up = Input.is_action_pressed(getMyInput("Up"))
	var jump = Input.is_action_pressed(getMyInput("Jump"))
	var down = Input.is_action_pressed(getMyInput("Down"))
	var attack = Input.is_action_just_pressed(getMyInput("Attack"))
	if(right != left):
		if(right):
			velocity.x = clamp(velocity.x + ACCELERATION, -MAXSPEED, MAXSPEED)
			$AnimatedSprite.flip_h = false
		else:
			velocity.x = clamp(velocity.x - ACCELERATION, -MAXSPEED, MAXSPEED)
			$AnimatedSprite.flip_h = true
	else:
		velocity.x = lerp(velocity.x, 0, FRICTION)
		if(abs(velocity.x) <= 20):
			setState(States.Idle)
	if(jump && is_on_floor()):
		velocity.y = -JUMPFORCE
		setState(States.Jump)
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, VECTOR_UP)
	
	if(!is_on_floor()):
		setState(States.Fall)
	
	if(disableImpulse):
		$ImpulseZone/CollisionShape2D.disabled = true
		
	if(attack):
		slash(getDirection(up, right, down, left))


func JumpProcess(delta):
	var right = Input.is_action_pressed(getMyInput("Right"))
	var left = Input.is_action_pressed(getMyInput("Left"))
	var up = Input.is_action_pressed(getMyInput("Up"))
	var down = Input.is_action_pressed(getMyInput("Down"))
	var attack = Input.is_action_just_pressed(getMyInput("Attack"))
	if(right != left):
		if(right):
			velocity.x = clamp(velocity.x + ACCELERATION * AIRCONTROLRATIO, -MAXSPEED, MAXSPEED)
			$AnimatedSprite.flip_h = false
		else:
			velocity.x = clamp(velocity.x - ACCELERATION * AIRCONTROLRATIO, -MAXSPEED, MAXSPEED)
			$AnimatedSprite.flip_h = true
	else:
		velocity.x = lerp(velocity.x, 0, FRICTION * AIRCONTROLRATIO)
	
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, VECTOR_UP)
	if(velocity.y >= 0):
		setState(States.Fall)
	
	if(disableImpulse):
		$ImpulseZone/CollisionShape2D.disabled = true
		
	if(attack):
		slash(getDirection(up, right, down, left))


func FallProcess(delta):
	var right = Input.is_action_pressed(getMyInput("Right"))
	var left = Input.is_action_pressed(getMyInput("Left"))
	var up = Input.is_action_pressed(getMyInput("Up"))
	var down = Input.is_action_pressed(getMyInput("Down"))
	var attack = Input.is_action_just_pressed(getMyInput("Attack"))
	if(right != left):
		if(right):
			velocity.x = clamp(velocity.x + ACCELERATION * AIRCONTROLRATIO, -MAXSPEED, MAXSPEED)
			$AnimatedSprite.flip_h = false
		else:
			velocity.x = clamp(velocity.x - ACCELERATION * AIRCONTROLRATIO, -MAXSPEED, MAXSPEED)
			$AnimatedSprite.flip_h = true
	else:
		velocity.x = lerp(velocity.x, 0, FRICTION * AIRCONTROLRATIO)
	
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, VECTOR_UP)
	if(is_on_floor()):
		setState(States.Walk)
	if(disableImpulse):
		$ImpulseZone/CollisionShape2D.disabled = true
		
	if(attack):
		slash(getDirection(up, right, down, left))


func CastProcess(delta):
	var right = Input.is_action_pressed(getMyInput("Right"))
	var left = Input.is_action_pressed(getMyInput("Left"))
	var up = Input.is_action_pressed(getMyInput("Up"))
	var jump = Input.is_action_just_pressed(getMyInput("Jump"))
	var down = Input.is_action_pressed(getMyInput("Down"))
	var attack = Input.is_action_just_pressed(getMyInput("Attack"))
	if(right != left):
		if(right):
			velocity.x = clamp(velocity.x + ACCELERATION, -MAXSPEED, MAXSPEED)
			$AnimatedSprite.flip_h = false
		else:
			velocity.x = clamp(velocity.x - ACCELERATION, -MAXSPEED, MAXSPEED)
			$AnimatedSprite.flip_h = true
	else:
		velocity.x = lerp(velocity.x, 0, FRICTION)
	if(jump && is_on_floor()):
		velocity.y = -JUMPFORCE
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, VECTOR_UP)
	
	if(disableImpulse):
		$ImpulseZone/CollisionShape2D.disabled = true
		
	if(attack):
		slash(getDirection(up, right, down, left))

func setState(newState):
	match(state):
		States.Idle:
			pass
		States.Walk:
			pass
		States.Jump:
			pass
		States.Fall:
			pass
		States.Cast:
			pass
	state = newState
	match(state):
		States.Idle:
			$AnimatedSprite.play("Idle")
		States.Walk:
			$AnimatedSprite.play("Run")
		States.Jump:
			$AnimatedSprite.play("Jump")
		States.Fall:
			$AnimatedSprite.play("Fall")
		States.Cast:
			$AnimatedSprite.play("Cast")


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
	var newPositionVector = getVectorFromDirection(slashDirection)
	if(newPositionVector.x != 0):
		if(newPositionVector.x > 0):
			$ImpulseZone.position.x = abs($ImpulseZone.position.x)
		else:
			$ImpulseZone.position.x = -abs($ImpulseZone.position.x)
	

func getMyInput(name : String):
	return name + str(controlMode)


func _on_ImpulseZone_body_entered(body):
	var impulse = Vector2()
	var FORCE = 500
	impulse = getVectorFromDirection(slashDirection)
	body.apply_central_impulse(impulse * FORCE)


func getVectorFromDirection(direction):
	var impulse = Vector2()
	match(direction):
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
	return impulse


func _on_AnimatedSprite_animation_finished():
	pass # Replace with function body.
