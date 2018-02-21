extends KinematicBody2D

const GRAVITY = 800
const SPEED_X = 750
const SPEED_Y = 1500
const TO_SCALE = 0.1
const SMOOTH = 0.3

const LIFETIME = 8.0

const ON_COLOR = Color(0.0, 1.0, 1.0, 1.0)

var shoot = false
var spin_speeds = [PI * 0.2, PI * 0.8, PI * 2.0]
var curr_spin_speed = 0.0
var count = 0
var timer

onready var straight_line_movement = preload("res://Scripts/Movements/StraightLineMovement.gd").new(SPEED_X, 0)
onready var gravity_movement = preload("res://Scripts/Movements/GravityMovement.gd").new(self, GRAVITY)

onready var holes = [
	$"Spinner/Hole 1",
	$"Spinner/Hole 2",
	$"Spinner/Hole 3"
]

func _process(delta):
	rotation += curr_spin_speed * delta

	if shoot:
		gravity_movement.move(delta)
		move_and_collide(straight_line_movement.movement(delta))

		scale = Vector2(1.0, 1.0) * lerp(scale.x, TO_SCALE, delta * SMOOTH)

func hit_and_check_if_complete():
	holes[count].set_modulate(ON_COLOR)
	holes[count].get_node("Sprite").set_modulate(ON_COLOR)

	curr_spin_speed = spin_speeds[count]

	count += 1
	if count == holes.size():
		gravity_movement.dy = -SPEED_Y

		timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(LIFETIME, self, "queue_free")

		return true
	else:
		return false