extends KinematicBody2D

export var controlMode = 1 # Can be 1 or 2 if player 1 or 2

const VECTOR_UP = Vector2(0, -1)
const SNAPVECTOR = Vector2(0, 10)
const MAXSPEED = 300
const FRICTION = 0.8
const ACCELERATION = 40
const AIRCONTROLRATIO = 0.1
const GRAVITY = 600
const JUMPFORCE = 400
const PUSH = 70

var velocity : Vector2
var disableImpulse = false

enum States{
	Idle, Walk, Jump, Fall, Cast, Attack
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
			States.Attack:
				AttackProcess(delta)
		if(Input.is_action_just_pressed(getMyInput("Activate")) && lastBoxes.size() != 0):
			for lastBox in lastBoxes:
				if(lastBox.has_method("StuckIt")):
					lastBox.StuckIt()
					lastBox = null
					setState(States.Cast)
			lastBoxes = []

func DoCustomMove(do_snap):
	velocity = move_and_slide_with_snap(velocity, int(do_snap)*SNAPVECTOR, VECTOR_UP, true, 4, deg2rad(50), false)
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if (collision.collider.is_in_group("pushables")):
			collision.collider.apply_central_impulse(-collision.normal * PUSH)


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
	DoCustomMove(true)
	
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
	DoCustomMove(true)
	
	if(!is_on_floor()):
		setState(States.Fall)
	
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
	DoCustomMove(false)
	#velocity = move_and_slide(velocity, VECTOR_UP)
	if(velocity.y >= 0):
		setState(States.Fall)
	
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
	DoCustomMove(true)
	#velocity = move_and_slide(velocity, VECTOR_UP)
	if(is_on_floor()):
		setState(States.Walk)
	
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
	
	DoCustomMove(true)
	#velocity = move_and_slide(velocity, VECTOR_UP)
	
	if(attack):
		slash(getDirection(up, right, down, left))


func AttackProcess(delta):
	var right = Input.is_action_pressed(getMyInput("Right"))
	var left = Input.is_action_pressed(getMyInput("Left"))
	var up = Input.is_action_pressed(getMyInput("Up"))
	var jump = Input.is_action_pressed(getMyInput("Jump"))
	var down = Input.is_action_pressed(getMyInput("Down"))
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
	
	DoCustomMove(true)#velocity = move_and_slide(velocity, VECTOR_UP)
	
	if(disableImpulse):
		$ImpulseZone/CollisionShape2D.disabled = true
	


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
	setState(States.Attack)
	disableImpulse = true
	slashDirection = direction
	if(slashDirection >= 2):
		$AnimatedSprite.play("AttackUp")
	else:
		$AnimatedSprite.play("AttackFront")
	
	$ImpulseZone/CollisionShape2D.disabled = false
	var newPositionVector = getVectorFromDirection(slashDirection)
	if(!$AnimatedSprite.flip_h):
		$ImpulseZone.position.x = abs($ImpulseZone.position.x)
	else:
		$ImpulseZone.position.x = -abs($ImpulseZone.position.x)
	

func getMyInput(name : String):
	return name + str(controlMode)


var lastBoxes = []
func _on_ImpulseZone_body_entered(body):
	lastBoxes.push_back(body)
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
	if(state == States.Attack ||state == States.Cast):
		setState(States.Walk)
