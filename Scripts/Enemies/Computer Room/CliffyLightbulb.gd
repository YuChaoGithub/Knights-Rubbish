extends KinematicBody2D

# Movement.
const SPEED = Vector2(600.0, 0.0)
const GRAVITY = 800
const BOUNCINESS = 0.7

# Attack.
const DAMAGE = 20
const KNOCK_BACK_VEL_X = 300
const KNOCK_BACK_VEL_Y = 300
const KNOCK_BACK_FADE_RATE = 600

const LIFETIME = 8.0

var timestamp = 0.0

var movement_pattern

onready var bounce_sound = $Bounce

func _ready():
	$AnimationPlayer.play("Blinking")

func initialize(dir_x):
	movement_pattern = preload("res://Scripts/Movements/BouncyMovement.gd").new(self, Vector2(dir_x * SPEED.x, SPEED.y), GRAVITY, BOUNCINESS)

func _process(delta):
	movement_pattern.move(delta)
	if movement_pattern.bounced:
		bounce_sound.play()

	timestamp += delta
	if timestamp > LIFETIME:
		explode()

func on_attack_hit(area):
	if area.is_in_group("hero"):
		var character = area.get_node("..")
		character.damaged(DAMAGE)
		character.knocked_back(sign(movement_pattern.velocity.x) * KNOCK_BACK_VEL_X, -KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)

		explode()

func explode():
	set_process(false)
	# Will be freed by the animation.
	$AnimationPlayer.play("Explode")