extends Node2D

# Movement.
const MAX_SPIN_SPEED_CAP = 800
const MIN_SPIN_SPEED_CAP = 600
const ACCELERATE_DURATION = 5
const SPEED_X = 1500

# Attack.
const DAMAGE = 25
const KNOCK_BACK_VEL_X = 750
const KNOCK_BACK_FADE_RATE = 1850
const KNOCK_BACK_VEL_Y = 0

const LIFETIME = 5

var lifetime_timestamp
var traveling = false
var curr_spin_speed = 0
var spin_speed_cap

var rng = preload("res://Scripts/Utils/RandomNumberGenerator.gd")

onready var movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(-SPEED_X, 0)

func _ready():
	# Random starting rotation.
	rotation_degrees = rng.randf_range(0.0, 359.0)

	# Random spin cap.
	spin_speed_cap = rng.randi_range(MIN_SPIN_SPEED_CAP, MAX_SPIN_SPEED_CAP)

func _process(delta):
	if !traveling:
		accelerate_spin(delta)
	else:
		position += movement_pattern.movement(delta)

		if OS.get_unix_time() - lifetime_timestamp >= LIFETIME:
			queue_free()

	rotation_degrees += curr_spin_speed * delta

func accelerate_spin(delta):
	curr_spin_speed += delta * spin_speed_cap / ACCELERATE_DURATION

func attack_hit(area):
	if traveling && area.is_in_group("hero"):
		var character = area.get_node("..")
		character.damaged(DAMAGE)
		character.knocked_back(-KNOCK_BACK_VEL_X, KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)
	
		set_process(false)
		$AnimationPlayer.play("Explode")

func start_travel():
	traveling = true
	lifetime_timestamp = OS.get_unix_time()