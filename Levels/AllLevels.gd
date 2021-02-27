extends Node2D

###### LOGIC FOR SCENE TRANSITIONS

export var SCREEN_WIDTH := 1200
export var SCREEN_HEIGHT := 900

var thunder = preload("res://TestZone/Thunder.tscn")

var levels := [
	preload("res://Levels/Level0.tscn"),
	preload("res://Levels/Level1.tscn"),
	preload("res://Levels/Level2.tscn")
]
var curr_lvl := 2

var _curr_scene_instance = null
var _next_scene_instance = null
var _curr_checkpoint_name := ""

func _goto_scene(new_scene):
	_next_scene_instance = new_scene
	$Timer.start()


# Called when the node enters the scene tree for the first time.
func _ready():
	_goto_scene(levels[curr_lvl].instance())
	$Timer.start($Timer.wait_time / 2)
	$CanvasLayer/Rect.scale = Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)
	label = $CanvasLayer/ColorRect/Label
	label_base_x = label.rect_position.x
	put_text("Je dois m'échapper...")


var last_progress = -1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:
		$CanvasLayer/Rect.scale = Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)
		return
	_process_text()
	var progress = 1 - $Timer.time_left / $Timer.wait_time
	$CanvasLayer/Rect.position.x = lerp(-SCREEN_WIDTH, SCREEN_WIDTH, progress)
	
	if last_progress < 0.5 and progress >= 0.5:
		if _curr_scene_instance != null:
			$SceneParent.remove_child(_curr_scene_instance)
			_curr_scene_instance.queue_free()
			
		_curr_scene_instance = _next_scene_instance
		_curr_scene_instance.connect("reached_end", self, "_on_reached_end")
		_curr_scene_instance.connect("reset_to_checkpoint", self, "_on_reset_to_checkpoint")
		_curr_scene_instance.connect("put_text", self, "put_text")
		player = _curr_scene_instance.get_node("Player")
		player.controlMode = playerNumber
		player.world = self
		
		$SceneParent.add_child(_curr_scene_instance)
		if _curr_checkpoint_name != "":
			_curr_scene_instance.goto_checkpoint(_curr_checkpoint_name)
	last_progress = progress

func _on_reached_end():
	_curr_checkpoint_name = ""
	curr_lvl += 1
	_goto_scene(levels[curr_lvl].instance())
	$Timer.start()

func _on_reset_to_checkpoint(name):
	_curr_checkpoint_name = name
	_goto_scene(levels[curr_lvl].instance())
	$Timer.start()
	


###### LOGIC FOR MULTIPLAYER

export var playerNumber = 1
export(NodePath) var otherWorld
var Box = preload("res://TestZone/Debris.tscn")

var player : KinematicBody2D

enum Objects{
	Boost, Boxes, Thunder
}

func applyObject(object):
	match(object):
		"Boost":
			player.applyObject(object)
		"Boxes":
			if(otherWorld):
				get_node(otherWorld).receiveObject(Objects.Boxes)
		"Thunder":
			if(otherWorld):
				get_node(otherWorld).receiveObject(Objects.Thunder)


func receiveObject(object):
	match(object):
		Objects.Boxes:
			for i in range(5):
				var box = Box.instance()
				box.setScale(rand_range(0.8, 2), rand_range(0.8, 2))
				box.global_position = player.global_position + Vector2(50 + rand_range(-20, +20), -50 + rand_range(-20, 20))
				_curr_scene_instance.get_node("AllDebris").add_child(box)
		Objects.Thunder:
			var thun = thunder.instance()
			thun.setPosition(player.global_position + Vector2(0, 10))
			_curr_scene_instance.add_child(thun)

###### LOGIC FOR TEXT

var label_base_x := 0
var label = null

func put_text(text):
	label.text = text
	$TextTimer.wait_time = text.length() / 12 + 3
	$TextTimer.start()

func _process_text():
	# display 10 characters per second
	label.visible_characters = 10 * ($TextTimer.wait_time - $TextTimer.time_left)
	
	var progress = 1 - $TextTimer.time_left / $TextTimer.wait_time
	if progress <= 0.5:
		# text appearing
		progress = inverse_lerp(0, 0.5, progress)
		label.modulate.a = progress
		label.rect_position.x = label_base_x + 200 * (1-progress) * (1-progress)
	elif progress <= 0.8:
		# text staying
		progress = inverse_lerp(0.5, 0.8, progress)
		label.modulate.a = 1
		label.rect_position.x = label_base_x
	else:
		# text disappearing
		progress = inverse_lerp(0.8, 1, progress)
		label.modulate.a = 1 - progress
		label.rect_position.x = label_base_x - 100 * progress * progress
	
