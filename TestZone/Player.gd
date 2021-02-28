extends KinematicBody2D
class_name Player

export var controlMode = 1 # Can be 1 or 2 if player 1 or 2
var world
var myBonus = null
var HUD

const VECTOR_UP = Vector2(0, -1)
const SNAPVECTOR = Vector2(0, 10)
var MAXSPEED = 400
const FRICTION = 0.8
var ACCELERATION = 70
const AIRCONTROLRATIO = 0.2
const GRAVITY = 1200
const JUMPFORCE = 300
const PUSH = 70
const COYOTE_TIME = 0.1
const JUMP_TIME = 0.4
const JUMP_HEIGHT = -150

var velocity : Vector2
var disableImpulse = false
var time_since_last_ground = 1000
var time_since_jump = 0
var has_control := true

var right = false
var left = false
var up = false
var jump = false
var down = false
var attack = false

var iceSound : AudioStreamSample

enum States{
	Idle, Walk, Jump, Fall, Cast, Attack
}


func _ready():
	velocity = Vector2(0, 0)
	HUD = $HUD
	iceSound = preload("res://Sounds/Ice attack 2.wav")


var state = States.Idle
func _physics_process(delta):
	if(!Engine.editor_hint):
		if(has_control):
			right = Input.is_action_pressed(getMyInput("Right"))
			left = Input.is_action_pressed(getMyInput("Left"))
			up = Input.is_action_pressed(getMyInput("Up"))
			jump = Input.is_action_pressed(getMyInput("Jump"))
			down = Input.is_action_pressed(getMyInput("Down"))
			attack = Input.is_action_just_pressed(getMyInput("Attack"))
			
			time_since_last_ground += delta
			time_since_jump += delta
			if (state != States.Jump and jump and time_since_last_ground <= COYOTE_TIME):
				StartJump()
			
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
					lastBox.StuckIt()
				if velocity.y < 0:
					velocity.y = 0
				setState(States.Cast)
				$AudioStreamPlayer.stream = iceSound
				$AudioStreamPlayer.play()
				removeBoxes()
			ObjectProcess(delta)
		else:
			move_and_slide(velocity)
			if(canPassEnd):
				if(Input.is_action_just_pressed(getMyInput("Jump"))):
					finish()
				

func DoCustomMove(do_snap):
	velocity = move_and_slide_with_snap(velocity, int(do_snap)*SNAPVECTOR, VECTOR_UP, true, 4, deg2rad(60), false)
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if (collision.collider.is_in_group("pushables")):
			var coef = clamp(abs(Vector2(1, 0).dot(collision.normal)), 0.2, 1)
			collision.collider.apply_central_impulse(-collision.normal * PUSH * coef)


func IdleProcess(delta):
	time_since_last_ground = 0
	
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
		StartJump()
	
	velocity.y += GRAVITY * delta
	DoCustomMove(true)
	
	if(attack):
		slash(getDirection(up, right, down, left))



func WalkProcess(delta):
	time_since_last_ground = 0
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
		StartJump()
	velocity.y += GRAVITY * delta
	DoCustomMove(true)
	
	if(!is_on_floor()):
		setState(States.Fall)
	
	if(attack):
		slash(getDirection(up, right, down, left))

func StartJump():
	velocity.y = -JUMPFORCE
	setState(States.Jump)
	time_since_jump = 0

func JumpProcess(delta):
	time_since_last_ground = 1000
	if(right != left):
		if(right):
			velocity.x = clamp(velocity.x + ACCELERATION * AIRCONTROLRATIO, -MAXSPEED, MAXSPEED)
			$AnimatedSprite.flip_h = false
		else:
			velocity.x = clamp(velocity.x - ACCELERATION * AIRCONTROLRATIO, -MAXSPEED, MAXSPEED)
			$AnimatedSprite.flip_h = true
	else:
		velocity.x = lerp(velocity.x, 0, FRICTION * AIRCONTROLRATIO)
	
	var progress = time_since_jump / JUMP_TIME
	velocity.y = 2 * JUMP_HEIGHT * (1-progress) / JUMP_TIME
	#velocity.y += GRAVITY * delta
	#elocity.y = velocity.y / 1.0001 + 1
	DoCustomMove(false)
	#velocity = move_and_slide(velocity, VECTOR_UP)
	if(progress >= 1 || !jump):
		velocity.y /= 3
		setState(States.Fall)
	
	if(attack):
		velocity.y /= 3
		slash(getDirection(up, right, down, left))


func FallProcess(delta):
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
		
	#if (jump and time_since_last_ground <= COYOTE_TIME):
	#	StartJump()
	
	if(attack):
		slash(getDirection(up, right, down, left))


func CastProcess(delta):
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
		StartJump()
	velocity.y += GRAVITY * delta
	
	DoCustomMove(true)
	#velocity = move_and_slide(velocity, VECTOR_UP)
	
	if(attack):
		slash(getDirection(up, right, down, left))


func AttackProcess(delta):
	if(right != left):
		if(right):
			velocity.x = clamp(velocity.x + ACCELERATION, -MAXSPEED, MAXSPEED)
			$AnimatedSprite.flip_h = false
		else:
			velocity.x = clamp(velocity.x - ACCELERATION, -MAXSPEED, MAXSPEED)
			$AnimatedSprite.flip_h = true
	else:
		velocity.x = lerp(velocity.x, 0, FRICTION)
	#if(jump && is_on_floor()):
	#	StartJump()
	velocity.y += GRAVITY * delta * 2
	
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
	removeBoxes()
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


var objectTimer = 0
var objectDuration = -1
var lastObjectUsed
func applyObject(object):
	removeObject()
	if(object == "Boost"):
		ACCELERATION *= 2
		MAXSPEED *= 2
		lastObjectUsed = object
		objectTimer = 0
		objectDuration = 5
	elif(object == "Thunder"):
		ACCELERATION /= 4
		MAXSPEED /= 4
		lastObjectUsed = object
		objectTimer = 0
		objectDuration = 5


func ObjectProcess(delta):
	if(objectTimer < objectDuration):
		objectTimer += delta
		if(objectTimer >= objectDuration):
			removeObject()
	if Input.is_action_just_pressed(getMyInput("Bonus")):
		UseObject()


func UseObject():
	if(myBonus == null):
		return
	world.applyObject(myBonus)
	HUD.setTexture(null)
	myBonus = null


func removeObject():
	objectDuration = -1
	if(lastObjectUsed == null):
		return
	if(lastObjectUsed == "Boost"):
		ACCELERATION /= 2
		MAXSPEED /= 2
	elif(lastObjectUsed == "Thunder"):
		ACCELERATION *= 4
		MAXSPEED *= 4
		$ThunderEffect.emitting = false
	$AnimatedSprite.self_modulate = Color.white
	
	lastObjectUsed = null


func getItem():
	return myBonus


func addItem():
	var allBonuses = ["Boost", "Boxes", "Thunder"]
	myBonus = allBonuses[rand_range(0, allBonuses.size())]
	HUD.setTexture(myBonus)


func Stun():
	applyObject("Thunder")
	$ThunderEffect.emitting = true
	$AnimatedSprite.self_modulate = Color.yellow


var lastBoxes = []

func appendBox(box):
	box.setStuckable(true)
	lastBoxes.push_back(box)

func removeBoxes():
	for box in lastBoxes:
		box.setStuckable(false)
	lastBoxes = []

func _on_ImpulseZone_body_entered(body):
	if body is Debris:
		appendBox(body)
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
		if time_since_last_ground > COYOTE_TIME:
			setState(States.Fall)
		else:
			setState(States.Walk)

func cameraZoneEnter(target, zoom):
	$Camera2D.setTarget(target, zoom)



func _on_AudioStreamPlayer2D_finished():
	$AudioStreamPlayer.stop()
	print("yeah")


func hit():
	get_parent().trigger_last_checkpoint(self)


func lockMovement():
	$AnimatedSprite.play("Run")
	$AnimatedSprite.flip_h = false
	velocity = Vector2(MAXSPEED, 0)
	has_control = false
	$Camera2D.drag_margin_bottom = 0
	$Camera2D.drag_margin_right = 0
	$Camera2D.drag_margin_left = 0
	$Camera2D.drag_margin_top = 0
	$Camera2D.smoothing_enabled = false
	$Camera2D.setTarget($Foot, Vector2(0.6, 0.6))

func teleportConstantBack(body):
	if(body == self):
		position.x -= 1600

var canPassEnd = false
func enableNextWorld():
	canPassEnd = true

func finish():
	canPassEnd = false
	var foot = $Foot
	var footGlobalPos = foot.global_position
	remove_child(foot)
	get_parent().add_child(foot)
	foot.global_position = footGlobalPos
	get_parent().finishGame()


func one_player_only():
	$HUD.scale.x = 0
