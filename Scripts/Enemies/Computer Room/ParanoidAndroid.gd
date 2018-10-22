extends KinematicBody2D

# Paranoid Android AI:
# 1. Falling straight down.
# 2. If landed on ground, start moving to the left.
# 3. Explode when collided with a character or after its lifetime.

# Movement.
const SPEED_X = 1500
const GRAVITY = 2000

# Attack.
const DAMAGE = 25
const KNOCK_BACK_VEL_X = 300
const KNOCK_BACK_FADE_RATE = 600
const KNOCK_BACK_VEL_Y = 300

const LIFETIME = 10

var lifetime_timestamp

onready var movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(-SPEED_X, 0)
onready var gravity_movement = preload("res://Scripts/Movements/GravityMovement.gd").new(self, GRAVITY)

onready var animator = $"Animation/AnimationPlayer"

func _ready():
	animator.play("Still")
	lifetime_timestamp = OS.get_unix_time()

func _process(delta):
	gravity_movement.move(delta)

	# Move horizontally only if it landed on ground.
	if gravity_movement.is_landed:
		move_and_collide(movement_pattern.movement(delta))

		if animator.current_animation != "Moving":
			animator.play("Moving")

	# Queue free if exceeds lifetime.
	if OS.get_unix_time() - lifetime_timestamp >= LIFETIME:
		explode()

func attack_hit(area):
	if area.is_in_group("hero"):
		explode()
		
		var character = area.get_node("..")
		character.damaged(DAMAGE)
		character.knocked_back(-KNOCK_BACK_VEL_X, -KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)

func explode():
	set_process(false)
	animator.play("Explode")	