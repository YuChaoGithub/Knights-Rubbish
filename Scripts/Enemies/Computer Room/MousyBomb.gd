extends KinematicBody2D

# Movement.
const SPEED_X = 500
const GRAVITY = 500

# Attack.
const DAMAGE = 50
const KNOCK_BACK_VEL_X = 500
const KNOCK_BACK_FADE_RATE = 1250
const KNOCK_BACK_VEL_Y = 500

const DIE_ANIMATION_DURATION = 0.2

var facing
var die_timer = null

onready var movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(facing * SPEED_X, 0)
onready var gravity_movement = preload("res://Scripts/Movements/GravityMovement.gd").new(self, GRAVITY)

onready var animator = get_node("AnimationPlayer")

func _ready():
	# Facing.
	set_scale(Vector2(-1 * get_scale().x * facing, get_scale().y))

	animator.play("Blink")

	set_process(true)

func _process(delta):
	var final_pos = movement_pattern.movement(get_global_pos(), delta)
	final_pos = gravity_movement.movement(final_pos, delta)
	move_to(final_pos)

func attack_hit(area):
	if area.is_in_group("player_collider"):
		var character = area.get_node("..")
		character.damaged(DAMAGE)
		character.knocked_back(facing * KNOCK_BACK_VEL_X, KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)
		
		# Explode animation.
		animator.play("Explode")
		die_timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(DIE_ANIMATION_DURATION, self, "queue_free")

		# Disable movement.
		set_process(false)