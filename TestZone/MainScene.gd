extends Node


var AudioPlayer : AudioStreamPlayer2D

func _ready():
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property($AudioStreamPlayer, "volume_db", -40, 0, 20, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
