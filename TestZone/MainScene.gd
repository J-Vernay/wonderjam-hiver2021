extends Node


var AudioPlayer : AudioStreamPlayer2D

var nb_players := 2

func _ready():
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property($AudioStreamPlayer, "volume_db", -20, -5, 20, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()

func one_player_only():
	$VBoxContainer/ViewportContainer2.queue_free()
	$VBoxContainer/ViewportContainer/Viewport1/AllLevels1.one_player_only()
	nb_players = 1

func _on_game_end():
	nb_players -= 1
	if nb_players == 0:
		get_tree().change_scene("res://TestZone/Menu.tscn")
		get_tree().get_root().remove_child(self)
