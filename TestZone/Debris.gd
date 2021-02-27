extends RigidBody2D
tool

export var SCALEX := 1.0
export var SCALEY := 1.0

var stuckTimer = 0;
var isStuck = false;
var oldLinearVelocity : Vector2
var oldAngularVelocity : float

const STUCK_TIME = 4

func _ready():
	$Sprite.scale.x = SCALEX
	$Sprite.scale.y = SCALEY
	$CollisionShape2D.scale.x = SCALEX * 0.92
	$CollisionShape2D.scale.y = SCALEY * 0.92
	add_to_group("pushables", true)

func _process(delta):
	if Engine.editor_hint:
		$Sprite.scale.x = SCALEX
		$Sprite.scale.y = SCALEY
		$CollisionShape2D.scale.x = SCALEX * 0.92
		$CollisionShape2D.scale.y = SCALEY * 0.92
	
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
	remove_from_group("pushables")

func UnStuckIt():
	isStuck = false
	mode = MODE_RIGID
	linear_velocity = oldLinearVelocity
	angular_velocity = oldAngularVelocity
	add_to_group("pushables", true)
