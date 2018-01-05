extends KinematicBody2D

const GRAVITY = 600
const DEFENSE_MODIFIER = 0.5
const DURATION = 5.0

onready var gravity_movement = preload("res://Scripts/Movements/GravityMovement.gd").new(self, GRAVITY)

func _ready():
	set_process(true)

func _process(delta):
	move_to(gravity_movement.movement(get_global_pos(), delta))

func on_area_entered(area):
	# A character enters.
	if area.is_in_group("player_collider"):
		area.get_node("..").defense_boosted(DEFENSE_MODIFIER, DURATION)

		queue_free()