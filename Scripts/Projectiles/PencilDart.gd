extends KinematicBody2D

var side
var damage_modifier
var size

const SPEED_X = 2250
const GRAVITY = 1200
const LIFE_TIME = 0.1
const DAMAGE = 20

# Ensure that only one target is hit.
var already_hit = false

var lifetime_timer

onready var movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(side * SPEED_X, 0)
onready var gravity_movement = preload("res://Scripts/Movements/GravityMovement.gd").new(self, GRAVITY)
onready var sprite = get_node("Sprite")

func initialize(side, damage_modifier, size):
	self.side = side
	self.damage_modifier = damage_modifier
	self.size = size

func _ready():
	# Set facing.
	sprite.set_scale(Vector2(sprite.get_scale().x * side, sprite.get_scale().y))

	# Set size.
	set_scale(get_scale() * size)

	set_process(true)

func _process(delta):
	# Move.
	var final_pos = movement_pattern.movement(get_global_pos(), delta)
	final_pos = gravity_movement.movement(final_pos, delta)
	move_to(final_pos)

	# Destroy when touches a platform.
	if self.is_colliding():
		movement_pattern.dx = 0
		gravity_movement.dy = 0
		gravity_movement.gravity = 0

		lifetime_timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(LIFE_TIME, self, "queue_free")

# Will be signalled when it hits an enemy.
func on_enemy_hit(area):
	if not already_hit and area.is_in_group("enemy_collider"):
		# Deal damage to enemy.
		area.get_node("../..").damaged(DAMAGE * damage_modifier)
		area.get_node("../..").slowed(0.2, 3)

		# Avoid damaging multiple targets.
		already_hit = true

		queue_free()