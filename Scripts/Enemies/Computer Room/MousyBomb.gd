extends KinematicBody2D

# Movement.
const SPEED_X = 700
const GRAVITY = 500

# Attack.
const DAMAGE = 18
const KNOCK_BACK_VEL_X = 500
const KNOCK_BACK_FADE_RATE = 1250
const KNOCK_BACK_VEL_Y = 500

const LIFETIME = 6

var lifetime_timestamp
var facing

onready var movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(facing * SPEED_X, 0)
onready var gravity_movement = preload("res://Scripts/Movements/GravityMovement.gd").new(self, GRAVITY)

onready var animator = $AnimationPlayer

func _ready():
	# Facing.
	scale = Vector2(-1 * scale.x * facing, scale.y)

	animator.play("Blink")
	lifetime_timestamp = OS.get_unix_time()

func _process(delta):
	gravity_movement.move(delta)
	move_and_collide(movement_pattern.movement(delta))

	if OS.get_unix_time() - lifetime_timestamp >= LIFETIME:
		explode()

func explode():
	set_process(false)

	# Will be freed by the animation.
	animator.play("Explode")

func attack_hit(area):
	if area.is_in_group("hero"):
		explode()
		
		var character = area.get_node("..")
		character.damaged(DAMAGE)
		character.knocked_back(facing * KNOCK_BACK_VEL_X, KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)