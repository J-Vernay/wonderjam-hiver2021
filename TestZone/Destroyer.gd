extends Area2D

func _on_Destroyer_body_entered(body):
	body.queue_free()
