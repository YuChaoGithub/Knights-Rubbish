extends KinematicBody2D

# Transform to Floggomine after a certain duration or when landed.

const SPEED_X = 500
const GRAVITY = 1000

const LIFETIME = 3.0
const FADE_TIME = 0.5

var timestamp = 0.0
var fade_timer = null

var straight_movement

var flaggomine = preload("res://Scenes/Enemies/Computer Room/Flaggomine Mine.tscn")

onready var animator = $AnimationPlayer
onready var gravity_movement = preload("res://Scripts/Movements/GravityMovement.gd").new(self, GRAVITY)

func initialize(dir_x):
	straight_movement = preload("res://Scripts/Movements/StraightLineMovement.gd").new(dir_x * SPEED_X, 0)

func _ready():
	animator.play("Still")

func _process(delta):
	gravity_movement.move(delta)
	move_and_collide(straight_movement.movement(delta))

	timestamp += delta
	if timestamp > LIFETIME || gravity_movement.is_landed:
		fade_timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(FADE_TIME, self, "turn_to_flaggomine")
		set_process(false)

func turn_to_flaggomine():
	var new_flaggomine = flaggomine.instance()
	$"..".add_child(new_flaggomine)
	new_flaggomine.global_position = global_position

	queue_free()