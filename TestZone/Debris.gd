extends RigidBody2D

func _ready():
	scale = Vector2(rand_range(0.5, 1.5), rand_range(0.5, 1.5))
	add_to_group("pushables", true)
