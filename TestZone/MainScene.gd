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
	$PauseMenu.Choices = ["Continuer", "Reset Joueur 1", "QUITTER"]


var pauseGame = false
func _process(delta):
	if(Input.is_action_just_pressed("Pause")):
		pauseGame = !pauseGame
		$VBoxContainer.get_tree().paused = pauseGame
		$PauseMenu.setPause(pauseGame)

func stopPause():
	pauseGame = false
	$VBoxContainer.get_tree().paused = pauseGame
	$PauseMenu.setPause(pauseGame)

func resetJoueur1():
	$VBoxContainer/ViewportContainer/Viewport1/AllLevels1._curr_scene_instance.goto_last_checkpoint()
	stopPause()

func resetJoueur2():
	$VBoxContainer/ViewportContainer2/Viewport2/AllLevels2._curr_scene_instance.goto_last_checkpoint()
	stopPause()
