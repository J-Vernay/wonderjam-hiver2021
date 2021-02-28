extends Area2D


func _on_ItemBox_body_entered(body):
	if(body.has_method("getItem")):
		if(!body.getItem()):
			body.addItem()
			queue_free()

var time = 0

func _process(delta):
	time += delta
	$Sprite.position.y += 1.5 * cos(5*time)
