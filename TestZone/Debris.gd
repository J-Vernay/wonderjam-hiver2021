class_name Debris
extends RigidBody2D
tool

export var SCALEX := 1.0
export var SCALEY := 1.0

var stuckTimer = 0;
var isStuck = false;
var oldLinearVelocity : Vector2
var oldAngularVelocity : float
var tween = null
var spawner = null

const STUCK_TIME = 4

func _ready():
	setScale(SCALEX, SCALEY)
	add_to_group("pushables", true)

func _process(delta):
	if Engine.editor_hint:
		setScale(SCALEX, SCALEY)
	
func _physics_process(delta):
	if(isStuck):
		stuckTimer += delta
		
		if(stuckTimer >= STUCK_TIME):
			UnStuckIt()

func setStuckable(stuckable):
	$Contour.visible = stuckable

func StuckIt():
	if tween == null :
		tween = Tween.new()
		add_child(tween)
	
	isStuck = true
	stuckTimer = 0
	oldLinearVelocity = linear_velocity
	oldAngularVelocity = angular_velocity
	linear_velocity = Vector2(0, 0)
	angular_velocity = 0
	mode = MODE_STATIC
	remove_from_group("pushables")
	tween.interpolate_property($Sprite, "self_modulate", Color(0, 2 , 4), Color(1, 1, 1), STUCK_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	$CPUParticles2D.emitting = true

func UnStuckIt():
	isStuck = false
	mode = MODE_RIGID
	linear_velocity = oldLinearVelocity
	angular_velocity = oldAngularVelocity
	add_to_group("pushables", true)
	$Sprite.self_modulate = Color(1, 1 , 1)

func setScale(scaleX, scaleY):
	SCALEX = scaleX
	SCALEY = scaleY
	$Sprite.scale.x = SCALEX
	$Sprite.scale.y = SCALEY
	$Contour.scale.x = SCALEX
	$Contour.scale.y = SCALEY
	$CollisionShape2D.scale.x = SCALEX * 0.92
	$CollisionShape2D.scale.y = SCALEY * 0.92
	$CPUParticles2D.scale.x = SCALEX
	$CPUParticles2D.scale.y = SCALEY
