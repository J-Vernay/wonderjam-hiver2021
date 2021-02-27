extends Node2D
tool

const MAXDISTANCE = 1000
const GROWTHTIME = 1
export var boxSize := Vector2(1, 1)

var growth = true
var growthTimer = 0

func _physics_process(delta):
	if !Engine.editor_hint:
		if(($Debris.global_position - global_position).length() > MAXDISTANCE):
			$Debris.angular_velocity = 0
			$Debris.linear_velocity = Vector2.ZERO
			$Debris.setScale(0, 0)
			$Debris.position = Vector2.ZERO
			growthTimer = 0
			growth = true
		if(growth):
			growthTimer += delta
			if(growthTimer > GROWTHTIME):
				growth = false
				$Debris.setScale(boxSize.x, boxSize.y)
			else:
				$Debris.setScale(boxSize.x * growthTimer / GROWTHTIME, boxSize.y * growthTimer / GROWTHTIME)
	

func _process(delta):
	if Engine.editor_hint:
		$Debris.setScale(boxSize.x, boxSize.y)
