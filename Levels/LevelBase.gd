class_name LevelBase
extends Node2D


signal reached_end # trigger for passing to the next level
signal reset_to_checkpoint(name) # ask parent to reset the scene, then the parent will call goto_checkpoint()

# SYSTÈME DE CHECKPOINT:
# Chaque checkpoint a un nom.
# Quand on atteint une zone de checkpoint, la fonction update_checkpoint(name) doit être appelée.
# Quand on veut se téléporter à un checkpoint, on envoit le signal reset_to_checkpoint(name).
# Le receveur du signal est responsable de réinitialiser la scène et d'appeler ensuite goto_checkpoint(name).


var _current_checkpoint = null
var _player = null

func _ready():
	_player = $Player
	_current_checkpoint = $Checkpoints.get_child(0)
	_player.position = _current_checkpoint.position
	
	
func update_checkpoint(body, checkpoint_name):
	print(checkpoint_name)
	var checkpoint = $Checkpoints.get_node(checkpoint_name)
	if checkpoint.get_index() > _current_checkpoint.get_index():
		print("ok")
		_current_checkpoint = checkpoint

func trigger_last_checkpoint(body):
	emit_signal("reset_to_checkpoint", _current_checkpoint.name)

func goto_checkpoint(name):
	update_checkpoint(null,name)
	_player.position = _current_checkpoint.position

func trigger_end():
	emit_signal("reached_end")
