extends Node


var Choices = [
	"Continuer",
	"Reset Joueur 1",
	"Reset Joueur 2",
	"QUITTER",
]


var current_selected := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in Choices.size():
		$CanvasLayer/Root/Choices.add_child($LabelModel.duplicate())
	_redraw_menu()



func _redraw_menu():
	var labels = $CanvasLayer/Root/Choices
	for i in Choices.size():
		if i == current_selected:
			labels.get_child(i).text = "> " + Choices[i] + " <"
		else:
			labels.get_child(i).text = Choices[i]

var cooldown = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!isPaused):
		return
	var up = Input.is_action_pressed("Up2") or Input.is_action_pressed("Up1")
	var down = Input.is_action_pressed("Down2") or Input.is_action_pressed("Down1")
	
	if not (up or down):
		cooldown = 0
	if cooldown > 0:
		cooldown -= delta
	else:
		var dir = int(down) - int(up)
		if dir != 0:
			current_selected = posmod(current_selected + dir, Choices.size())
			cooldown = 0.3
			_redraw_menu()
		elif Input.is_action_pressed("ui_accept"):
			match Choices[current_selected]:
				"Continuer":
					get_parent().stopPause()
				"Reset Joueur 1":
					get_parent().resetJoueur1()
				"Reset Joueur 2":
					get_parent().resetJoueur2()
				"QUITTER":
					get_parent().stopPause()
					get_tree().change_scene("res://TestZone/Menu.tscn")
					get_tree().get_root().remove_child(get_parent())

var isPaused = false
func setPause(pause):
	isPaused = pause
	$CanvasLayer.layer = -int(!pause)
