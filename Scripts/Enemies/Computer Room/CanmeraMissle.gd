extends KinematicBody2D

# Movement.
const SPEED = 1000
const GRAVITY = 400

# Attack.
const DAMAGE = 60
const KNOCK_BACK_VEL_X = 400
const KNOCK_BACK_FADE_RATE = 900
const KNOCK_BACK_VEL_Y = 300

const LIFETIME = 8

var lifetime_timestamp

var horizontal_movement
var gravity_movement

onready var animator = $AnimationPlayer

func initialize(dx, dy):
	horizontal_movement = preload("res://Scripts/Movements/StraightLineMovement.gd").new(dx * SPEED, 0)
	gravity_movement = preload("res://Scripts/Movements/GravityMovement.gd").new(self, GRAVITY)
	gravity_movement.dy = dy * SPEED

	lifetime_timestamp = OS.get_unix_time()

func _process(delta):
	# Movement.
	gravity_movement.move(delta)
	var collision = move_and_collide(horizontal_movement.movement(delta))

	# Rotation.
	rotation = atan2(-horizontal_movement.dx, gravity_movement.dy) - PI * 0.5

	# Lifetime.
	if collision != null || OS.get_unix_time() - lifetime_timestamp > LIFETIME:
		explode()

func explode():	
	# Will be freed by the animation.
	animator.play("Explode")
	set_process(false)

func attack_hit(area):
	if area.is_in_group("hero"):
		explode()

		var character = area.get_node("..")
		character.damaged(DAMAGE)
		character.knocked_back(-KNOCK_BACK_VEL_X, -KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)