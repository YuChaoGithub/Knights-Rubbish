extends KinematicBody2D

# Movement.
const SPEED = 1000
const GRAVITY = 400

# Attack.
const DAMAGE = 60
const KNOCK_BACK_VEL_X = 400
const KNOCK_BACK_FADE_RATE = 900
const KNOCK_BACK_VEL_Y = 300

const EXPLODE_DURATION = 0.2
const LIFETIME = 8

var lifetime_timestamp
var exploding = false
var explode_timer = null

var horizontal_movement
var gravity_movement

onready var animator = get_node("AnimationPlayer")

func initialize(dx, dy):
	horizontal_movement = preload("res://Scripts/Movements/StraightLineMovement.gd").new(dx * SPEED, 0)
	gravity_movement = preload("res://Scripts/Movements/GravityMovement.gd").new(self, GRAVITY)
	gravity_movement.dy = dy * SPEED
		
	set_process(true)

	lifetime_timestamp = OS.get_unix_time()

func _process(delta):
	# Movement.
	var final_pos = horizontal_movement.movement(get_global_pos(), delta)
	final_pos = gravity_movement.movement(final_pos, delta)
	move_to(final_pos)

	# Rotation.
	set_rot(atan2(-horizontal_movement.dx, -gravity_movement.dy) - PI * 0.5)

	# Lifetime.
	if gravity_movement.is_landed() || OS.get_unix_time() - lifetime_timestamp > LIFETIME:
		explode()

func explode():
	exploding = true
	
	animator.play("Explode")
	explode_timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(EXPLODE_DURATION, self, "queue_free")

	set_process(false)

func attack_hit(area):
	if !exploding && area.is_in_group("player_collider"):
		explode()

		var character = area.get_node("..")
		character.damaged(DAMAGE)
		character.knocked_back(-KNOCK_BACK_VEL_X, -KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)