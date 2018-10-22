extends Node2D

const SPEED_X = 1250

const DAMAGE = 15
const KNOCK_BACK_VEL_X = 600
const KNOCK_BACK_VEL_Y = 0
const KNOCK_BACK_FADE_RATE = 1200

const LIFETIME = 8.0

var timestamp = 0.0

var traveling = false
var dir_x

var movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(0, 0)

onready var animator = $AnimationPlayer

func _ready():
	animator.play("Blinking")

func initialize(dir_x):
	self.dir_x = dir_x
	scale = Vector2(scale.x * -dir_x, scale.y)
	set_process(true)

func _process(delta):
	global_position += movement_pattern.movement(delta)

	timestamp += delta
	if timestamp > LIFETIME:
		explode()

func start_travel():
	traveling = true
	animator.play("Traveling")
	movement_pattern.dx = dir_x * SPEED_X

func on_attack_hit(area):
	if traveling && area.is_in_group("hero"):
		var character = area.get_node("..")
		character.damaged(DAMAGE)
		character.knocked_back(dir_x * KNOCK_BACK_VEL_X, KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)

		explode()

func explode():
	set_process(false)
	# Will be freed by the animation.
	$AnimationPlayer.play("Explode")