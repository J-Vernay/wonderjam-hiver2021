extends CanvasLayer


export(Array, Texture) var itemsTexture

func setTexture(object):
	var index = -1
	if(object == "Boost"):
		index = 0
	elif(object == "Boxes"):
		index = 1
	
	if(index == -1 || index >= itemsTexture.size()):
		$TextureRect.texture = null
		return
	$TextureRect.texture = itemsTexture[index]
