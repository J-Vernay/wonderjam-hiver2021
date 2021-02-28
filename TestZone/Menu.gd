extends Node


var Choices = [
	"1 JOUEUR",
	"2 JOUEURS",
	"QUITTER",
]


var current_selected := 0

var main_scene := preload("res://TestZone/MainScene.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in Choices.size():
		$Root/Choices.add_child($LabelModel.duplicate())
	_redraw_menu()



func _redraw_menu():
	var labels = $Root/Choices
	for i in Choices.size():
		if i == current_selected:
			labels.get_child(i).text = "> " + Choices[i] + " <"
		else:
			labels.get_child(i).text = Choices[i]

var cooldown = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Node2D/ParallaxBackground.scroll_offset.x -= delta * 200
	$Node2D/Node2D.position.x = fposmod($Node2D/Node2D.position.x - delta * 300, 1200) - 1200
	
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
		elif Input.is_action_just_pressed("ui_accept"):
			$AudioStreamPlayer.stop()
			match Choices[current_selected]:
				"1 JOUEUR":
					var next = main_scene.instance()
					next.one_player_only()
					get_tree().get_root().add_child(next)
					get_tree().get_root().remove_child(self)
				"2 JOUEURS":
					var next = main_scene.instance()
					get_tree().get_root().add_child(next)
					get_tree().get_root().remove_child(self)
				"QUITTER":
					get_tree().quit()
		
		
