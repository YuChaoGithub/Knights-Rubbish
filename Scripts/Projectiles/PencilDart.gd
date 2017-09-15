extends Node2D

# Which side should it travel. Should be set when instancing.
var side

const SPEED_X = 3000.0
const SPEED_Y = 0.0
const LIFE_TIME = 3.0

# Initialized in _ready().
var movement_pattern

# For life time.
onready var start_timestamp = OS.get_unix_time()

func _ready():
	# Initialize movement pattern.
	# Pencil dart goes in a straight horizontal line.
	movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(SPEED_X * side, SPEED_Y)

	# Set facing.
	var sprite = get_node("Sprite")
	sprite.set_scale(Vector2(sprite.get_scale().x * side, sprite.get_scale().y))

	set_process(true)

func _process(delta):
	# If it passes the life time, destroy itself.
	if OS.get_unix_time() - start_timestamp >= LIFE_TIME:
		destroy()
		return

	# Move.
	set_global_pos(movement_pattern.movement(get_global_pos(), delta))

func destroy():
	# TODO: (Animations?)
	queue_free()