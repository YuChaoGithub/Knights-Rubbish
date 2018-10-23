extends KinematicBody2D

var side
var attack_modifier
var size

const SPEED_X = 2250
const GRAVITY = 2000
const SLIP_RATIO = 0.25
const TOTAL_LIFE_TIME = 2.0
const DAMAGE_INIT = 40
const DAMAGE_FINAL = 20
const DAMAGE_SCALE_TIME = 0.5

var damage

var timestamp = 0.0

onready var movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(side * SPEED_X, 0)
onready var gravity_movement = preload("res://Scripts/Movements/GravityMovement.gd").new(self, GRAVITY)
onready var sprite = $Sprite

func initialize(side, attack_modifier, size):
	self.side = side
	self.attack_modifier = attack_modifier
	self.size = size
	damage = DAMAGE_INIT

func _ready():
	# Set facing.
	scale.x *= side

	# Set size.
	scale = scale * size

func _process(delta):
	# Move.
	gravity_movement.move(delta)
	var collision = move_and_collide(movement_pattern.movement(delta))

	# Destroy when touches a platform.
	if gravity_movement.is_landed || collision != null:
		movement_pattern.dx *= SLIP_RATIO
		gravity_movement.dy = 0
		gravity_movement.gravity = 0

		fade_out()

	timestamp += delta

	damage = lerp(DAMAGE_INIT, DAMAGE_FINAL, timestamp / DAMAGE_SCALE_TIME)

	if timestamp >= TOTAL_LIFE_TIME:
		queue_free()

# Will be signalled when it hits an enemy.
func on_enemy_hit(area):
	if area.is_in_group("enemy"):
		area.get_node("../..").damaged(int(damage * attack_modifier))

		fade_out()

func fade_out():
	$AnimationPlayer.play("Fade")