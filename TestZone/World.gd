extends Node2D


export var playerNumber = 1

func _ready():
	$Player.controlMode = playerNumber
