extends RigidBody2D
tool

export var SCALEX := 1.0
export var SCALEY := 1.0

func _process(delta):
	if Engine.editor_hint:
		setScale(SCALEX, SCALEY)


func setScale(scaleX, scaleY):
	SCALEX = scaleX
	SCALEY = scaleY
	$Sprite.scale.x = SCALEX
	$Sprite.scale.y = SCALEY
	$CollisionShape2D.scale.x = SCALEX * 0.92
	$CollisionShape2D.scale.y = SCALEY * 0.92
	$Area2D.scale.x = SCALEX
	$Area2D.scale.y = SCALEY


func _on_Area2D_body_entered(body):
	print(body)
	if(body.has_method("hit")):
		body.hit()
