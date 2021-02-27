extends Node2D

export var SCREEN_WIDTH := 1200
export var SCREEN_HEIGHT := 900

var levels := [
	preload("res://Levels/Level0.tscn"),
	preload("res://Levels/Level1.tscn"),
]
var curr_lvl := 0

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


var last_progress = -1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:
		$CanvasLayer/Rect.scale = Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)
		return
	var progress = 1 - $Timer.time_left / $Timer.wait_time
	$CanvasLayer/Rect.position.x = lerp(-SCREEN_WIDTH, SCREEN_WIDTH, progress)
	
	if last_progress < 0.5 and progress >= 0.5:
		if _curr_scene_instance != null:
			$SceneParent.remove_child(_curr_scene_instance)
			_curr_scene_instance.queue_free()
		_curr_scene_instance = _next_scene_instance
		_curr_scene_instance.connect("reached_end", self, "_on_reached_end")
		_curr_scene_instance.connect("reset_to_checkpoint", self, "_on_reset_to_checkpoint")
		$SceneParent.add_child(_curr_scene_instance)
		if _curr_checkpoint_name != "":
			_curr_scene_instance.goto_checkpoint(_curr_checkpoint_name)
	last_progress = progress

func _on_reached_end():
	_curr_checkpoint_name = ""

func _on_reset_to_checkpoint(name):
	print("hi")
	last_progress = -1
	_curr_checkpoint_name = name
	_goto_scene(levels[curr_lvl].instance())
	$Timer.start()
