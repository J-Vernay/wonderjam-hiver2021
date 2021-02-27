extends Area2D


func _on_ItemBox_body_entered(body):
	if(body.has_method("getItem")):
		if(!body.getItem()):
			body.addItem()
			queue_free()
