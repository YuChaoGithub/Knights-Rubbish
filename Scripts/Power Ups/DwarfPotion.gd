extends KinematicBody2D

const GRAVITY = 600
const SIZE_MODIFIER = 0.5
const DAMAGE_MODIFIER = 0.75
const DEFENSE_MODIFIER = 1.2
const SELF_KNOCK_BACK_MODIFIER = 1.5
const ENEMY_KNOCK_BACK_MODIFIER = 0.5
const DURATION = 6.0

onready var gravity_movement = preload("res://Scripts/Movements/GravityMovement.gd").new(self, GRAVITY)

func _ready():
	set_process(true)

func _process(delta):
	move_to(gravity_movement.movement(get_global_pos(), delta))

func on_area_entered(area):
	# A character enters.
	if area.is_in_group("player_collider"):
		var multipliers = {
			size = SIZE_MODIFIER,
			damage = DAMAGE_MODIFIER,
			defense = DEFENSE_MODIFIER,
			self_knock_back = SELF_KNOCK_BACK_MODIFIER,
			enemy_knock_back = ENEMY_KNOCK_BACK_MODIFIER
		}
		area.get_node("..").dwarfed_or_gianted(multipliers, DURATION)
		
		queue_free()