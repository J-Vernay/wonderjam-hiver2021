extends RigidBody2D

var stuckTimer = 0;
var isStuck = false;
var oldLinearVelocity : Vector2
var oldAngularVelocity : float

const STUCK_TIME = 4

func _ready():
	scale = Vector2(rand_range(0.5, 1.5), rand_range(0.5, 1.5))
	add_to_group("pushables", true)
	
func _physics_process(delta):
	if(isStuck):
		stuckTimer += delta
		if(stuckTimer >= STUCK_TIME):
			UnStuckIt()

func StuckIt():
	isStuck = true
	stuckTimer = 0
	oldLinearVelocity = linear_velocity
	oldAngularVelocity = angular_velocity
	linear_velocity = Vector2(0, 0)
	angular_velocity = 0
	mode = MODE_STATIC

func UnStuckIt():
	isStuck = false
	mode = MODE_RIGID
	linear_velocity = oldLinearVelocity
	angular_velocity = oldAngularVelocity
