extends Area2D


func setPosition(position):
	global_position = position
	$AnimatedSprite.play("default")


func destroy():
	queue_free()


func _on_Thunder_body_entered(body):
	if(body.has_method("Stun")):
		body.Stun()
