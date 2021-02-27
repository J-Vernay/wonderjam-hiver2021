extends Area2D

export(Vector2) var zoom = Vector2(1.2, 1.2)

func _on_CameraZone_body_entered(body):
	if(body.has_method("cameraZoneEnter")):
		body.cameraZoneEnter(self, zoom)


func _on_CameraZone_body_exited(body):
	if(body.has_method("cameraZoneEnter")):
		get_node("Camera2D").removeTarget()
