extends KinematicBody2D

# Which side should it travel. Should be set when instancing.
var side

const SPEED_X = 2250
const GRAVITY = 1200
const LIFE_TIME = 0.1
const DAMAGE = 214

# Initialized in _ready().
var movement_pattern

# Ensure that only one target is hit.
var already_hit = false

var lifetime_timer

func _ready():
	# Initialize movement pattern.
	# Pencil dart goes in a straight horizontal line.
	movement_pattern = preload("res://Scripts/Movements/HorizontalMovementWithGravity.gd").new(SPEED_X * side, GRAVITY, self)

	# Set facing.
	var sprite = get_node("Sprite")
	sprite.set_scale(Vector2(sprite.get_scale().x * side, sprite.get_scale().y))

	set_process(true)

func _process(delta):
	# Move.
	move_to(movement_pattern.movement(get_global_pos(), delta))

	# Destroy when touches a platform.
	if self.is_colliding():
		movement_pattern.dx = 0
		movement_pattern.dy = 0
		movement_pattern.gravity = 0

		lifetime_timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(LIFE_TIME, self, "queue_free")

# Will be signalled when it hits an enemy.
func on_enemy_hit(area):
	if not already_hit and area.is_in_group("enemy_collider"):
		# Deal damage to enemy.
		area.get_node("../..").damaged(DAMAGE)

		# Avoid damaging multiple targets.
		already_hit = true

		queue_free()