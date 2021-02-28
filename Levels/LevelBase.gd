class_name LevelBase
extends Node2D


signal reached_end # trigger for passing to the next level
signal reset_to_checkpoint(pos) # ask parent to reset the scene, then the parent will call goto_checkpoint()

signal put_text(text)

# SYSTÈME DE CHECKPOINT:
# Chaque checkpoint a un nom.
# Quand on atteint une zone de checkpoint, la fonction update_checkpoint(name) doit être appelée.
# Quand on veut se téléporter à un checkpoint, on envoit le signal reset_to_checkpoint(name).
# Le receveur du signal est responsable de réinitialiser la scène et d'appeler ensuite goto_checkpoint(name).


var _current_checkpoint = null
var _player = null
var allLevels = null

func _ready():
	_player = $Player
	if(has_node("MappingJ1")):
		if _player.controlMode == 1:
			$MappingJ2.visible = false
		else:
			$MappingJ1.visible = false
	_current_checkpoint = $Checkpoints.get_child(0)
	goto_checkpoint(_current_checkpoint.name)
	_player.position = _current_checkpoint.position

	
func update_checkpoint(__, checkpoint_name):
	var checkpoint = $Checkpoints.get_node(checkpoint_name)
	if checkpoint.get_position_in_parent() > _current_checkpoint.get_position_in_parent():
		_current_checkpoint = checkpoint

func trigger_last_checkpoint(__):
	emit_signal("reset_to_checkpoint", _current_checkpoint.name)

func goto_checkpoint(name):
	update_checkpoint(null,name)
	goto_last_checkpoint()

func goto_last_checkpoint():
	_player.get_node("Camera2D").smoothing_enabled = false
	_player.position = _current_checkpoint.position

func trigger_end(__):
	emit_signal("reached_end")
	
func trigger_text(__, text):
	emit_signal("put_text", text)

func _process(delta):
	if(_player.has_node("Camera2D") && _player.has_control):
		var camera = _player.get_node("Camera2D")
		if camera != null:
			camera.smoothing_enabled = true

var finalScore = 0
func finishWorld(__):
	_player.lockMovement()
	var curr_val = OS.get_ticks_msec() - allLevels.start_of_timer
	var minutes = int(curr_val / 60000)
	curr_val = curr_val % 60000
	var seconds = int(curr_val / 1000)
	var millisec = curr_val % 1000
	
	var text = "%02d:%02d.%03d" % [ minutes, seconds, millisec ]
	var label = allLevels.stopTimer().duplicate()
	if(has_node("HUD")):
		get_node("HUD").add_child(label)
		label.visible = true
		var tween = Tween.new()
		add_child(tween)
		tween.interpolate_property(label, "margin_left", label.margin_left, 392, 2, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.interpolate_property(label, "margin_top", label.margin_top, 166, 2, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.interpolate_property(label, "margin_right", label.margin_right, 162, 2, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.interpolate_property(label, "margin_bottom", label.margin_bottom, 234, 2, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.interpolate_property(label, "rect_scale", label.rect_scale, Vector2(1.2, 1.2), 2, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()
		var timer = Timer.new()
		add_child(timer)
		timer.connect("timeout", self, "enableFinishPossibility")
		timer.set_wait_time(2)
		timer.one_shot = true
		timer.start()

func enableFinishPossibility():
	_player.enableNextWorld()
	$HUD/Label.visible = true

func finishGame():
		$HUD/Label.visible = false
		var timer = Timer.new()
		add_child(timer)
		timer.connect("timeout", self, "trigger_end", [self])
		timer.set_wait_time(3) #3 secondes pour permettre de voir le joueur s'en aller de l'écran avant de charger la nouvelle scene
		timer.one_shot = true
		timer.start()
