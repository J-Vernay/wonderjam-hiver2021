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
	_player.get_node("Camera2D").smoothing_enabled = false
	_player.position = _current_checkpoint.position

func trigger_end(__):
	emit_signal("reached_end")
	
func trigger_text(__, text):
	emit_signal("put_text", text)

func _process(delta):
	if(_player.has_node("Camera2D")):
		var camera = _player.get_node("Camera2D")
		if camera != null:
			camera.smoothing_enabled = true
