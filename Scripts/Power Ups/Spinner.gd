extends KinematicBody2D

const GRAVITY = 800
const SPEED_X = 2000
const SPEED_Y = 800
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
	get_node("Spinner/Hole 1"),
	get_node("Spinner/Hole 2"),
	get_node("Spinner/Hole 3")
]

func _ready():
	set_process(true)

func _process(delta):
	rotate(curr_spin_speed * delta)

	if shoot:
		var final_pos = straight_line_movement.movement(get_global_pos(), delta)
		final_pos = gravity_movement.movement(final_pos, delta)
		move_to(final_pos)

		set_scale(Vector2(1.0,1.0) * lerp(get_scale().x, TO_SCALE, delta * SMOOTH))

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