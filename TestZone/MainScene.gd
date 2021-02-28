extends Node


var AudioPlayer : AudioStreamPlayer2D

func _ready():
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property($AudioStreamPlayer, "volume_db", -20, -5, 20, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()

func one_player_only():
	$VBoxContainer/ViewportContainer2.queue_free()
	$VBoxContainer/ViewportContainer/Viewport1/AllLevels1.one_player_only()
