extends Node2D

# Which side should it travel. Should be set when instancing.
var side

const SPEED_X = 2250.0
const SPEED_Y = 0.0
const LIFE_TIME = 0.25
const DAMAGE = 5

# Initialized in _ready().
var movement_pattern

# Ensure that only one target is hit.
var already_hit = false

var lifetime_timer

func _ready():
	# Initialize movement pattern.
	# Pencil dart goes in a straight horizontal line.
	movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(SPEED_X * side, SPEED_Y)

	# Set facing.
	var sprite = get_node("Sprite")
	sprite.set_scale(Vector2(sprite.get_scale().x * side, sprite.get_scale().y))

	# Destroy when reaches lifetime.
	lifetime_timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(LIFE_TIME, self, "destroy")

	set_process(true)

func _process(delta):
	# Move.
	set_global_pos(movement_pattern.movement(get_global_pos(), delta))

# Will be signalled when it hits an enemy.
func on_enemy_hit(area):
	if not already_hit and area.is_in_group("enemy_collider"):
		# Deal damage to enemy.
		area.get_node("..").damaged(DAMAGE)

		# Avoid damaging multiple targets.
		already_hit = true

		# Canel lifetime timer.
		lifetime_timer.destroy_timer()

		destroy()

func destroy():
	# TODO: (Animations?)
	queue_free()