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
const DIE_ANIMATION_DURATION = 0.2

var lifetime_timestamp
var die_timer = null
var exploding = false

onready var movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(-SPEED_X, 0)
onready var gravity_movement = preload("res://Scripts/Movements/GravityMovement.gd").new(self, GRAVITY)

onready var animator = get_node("Animation/AnimationPlayer")

func _ready():
	animator.play("Still")
	set_process(true)
	lifetime_timestamp = OS.get_unix_time()

func _process(delta):
	var final_pos = gravity_movement.movement(get_global_pos(), delta)

	# Move horizontally only if it landed on ground.
	if gravity_movement.is_landed():
		final_pos = movement_pattern.movement(final_pos, delta)

		if animator.get_current_animation() != "Moving":
			animator.play("Moving")
	
	move_to(final_pos)

	# Queue free if exceeds lifetime.
	if OS.get_unix_time() - lifetime_timestamp >= LIFETIME:
		explode()

func attack_hit(area):
	if area.is_in_group("player_collider"):
		explode()
		var character = area.get_node("..")
		character.damaged(DAMAGE)
		character.knocked_back(-KNOCK_BACK_VEL_X, -KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)

func explode():
	exploding = true
	animator.play("Explode")
	die_timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(DIE_ANIMATION_DURATION, self, "queue_free")
	set_process(false)