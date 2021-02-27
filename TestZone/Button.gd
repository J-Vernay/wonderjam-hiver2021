extends StaticBody2D

var isPressed = false
var isActivate = false
var isNormal = true
signal activate
signal desactivate
const BUTTONSPEED = 20

func _physics_process(delta):
	if(isPressed):
		if(!isActivate):
			$MovingPart.position = goTo($MovingPart.position, $End.position, BUTTONSPEED * delta)
			if($MovingPart.position == $End.position):
				emit_signal("activate")
				isActivate = true
	else:
		if(!isNormal):
			$MovingPart.position = goTo($MovingPart.position, $Begin.position, BUTTONSPEED * delta)
			if($MovingPart.position == $Begin.position):
				isNormal = true

var bodiesPressing = []
func _on_Area2D_body_entered(body):
	print(body.name)
	isNormal = false
	isPressed = true
	bodiesPressing.push_back(body)


func _on_Area2D_body_exited(body):
	bodiesPressing.erase(body)
	if(bodiesPressing.size() <= 0):
		isPressed = false
		isActivate = false
		emit_signal("desactivate")


func goTo(from : Vector2, to : Vector2, delta : float):
	if(from.distance_to(to) <= delta):
		return to
	return from + (to - from).normalized() * delta
