extends KinematicBody2D

const GRAVITY = 600
const DAMAGE_MODIFIER = 2.0
const DURATION = 5.0

onready var gravity_movement = preload("res://Scripts/Movements/GravityMovement.gd").new(self, GRAVITY)

func _ready():
	set_process(true)

func _process(delta):
	move_to(gravity_movement.movement(get_global_pos(), delta))

func on_area_entered(area):
	# A character enters.
	if area.is_in_group("player_collider"):
		area.get_node("..").damage_boosted(DAMAGE_MODIFIER, DURATION)
		queue_free()