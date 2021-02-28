extends Area2D
tool

export var initialVelocity : Vector2
var lastBall : RigidBody2D
var SpikeBall

func _ready():
	lastBall = $SpikeBall
	lastBall.linear_velocity = initialVelocity
	SpikeBall = preload("res://TestZone/SpikeBall.tscn")

func _on_SpikeBallSpawner_body_exited(body):
	if(body == lastBall):
		lastBall = SpikeBall.instance()
		lastBall.linear_velocity = initialVelocity
		call_deferred("add_child", lastBall)

export var SCALEX := 1.0
export var SCALEY := 1.0

func _process(delta):
	if Engine.editor_hint:
		setScale(SCALEX, SCALEY)


func setScale(scaleX, scaleY):
	SCALEX = scaleX
	SCALEY = scaleY
	$SpikeBall.setScale(SCALEX, SCALEY)
