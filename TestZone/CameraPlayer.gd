extends Camera2D

var player
var zoomTarget = Vector2(1.2, 1.2)

func _ready():
	player = get_parent()

func _physics_process(delta):
	zoom = goTo(zoom, zoomTarget, delta)

func setTarget(target, newZoom):
	get_parent().remove_child(self)
	target.add_child(self)
	zoomTarget = newZoom

func removeTarget():
	get_parent().remove_child(self)
	player.add_child(self)
	zoomTarget = Vector2(1.2, 1.2)

func goTo(from : Vector2, to : Vector2, delta : float):
	if(from.distance_to(to) <= delta):
		return to
	return from + (to - from).normalized() * delta
