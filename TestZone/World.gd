extends Node2D


export var playerNumber = 1
export(NodePath) var otherWorld
var Box = preload("res://TestZone/Debris.tscn")

var player : KinematicBody2D

enum Objects{
	Boost, Boxes, Thunder
}

func _ready():
	player = $Player
	player.controlMode = playerNumber


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
				$AllDebris.add_child(box)
		Objects.Thunder:
			player.applyObject("Thunder")
