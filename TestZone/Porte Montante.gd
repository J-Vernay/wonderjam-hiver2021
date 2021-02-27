extends StaticBody2D
tool

export var isOpening = false
var animationOver = true
const OPENINGSPEED = 90

func open():
	isOpening = true
	animationOver = false

func _process(delta):
	if Engine.editor_hint:
		if(isOpening):
			$CollisionShape2D.position = $End.position
		else:
			$CollisionShape2D.position = $Begin.position

func close():
	isOpening = false
	animationOver = false

func _physics_process(delta):
	if(!animationOver):
		var target : Vector2
		if(isOpening):
			target = $End.position
		else:
			target = $Begin.position
		$CollisionShape2D.position = goTo($CollisionShape2D.position, target, OPENINGSPEED * delta)
		if($CollisionShape2D.position == target):
			animationOver = true


func goTo(from : Vector2, to : Vector2, delta : float):
	if(from.distance_to(to) <= delta):
		return to
	return from + (to - from).normalized() * delta

