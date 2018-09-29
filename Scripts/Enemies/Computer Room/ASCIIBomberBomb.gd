extends KinematicBody2D

const SPEED_X = 1000
const GRAVITY = 400

const DAMAGE = 30
const KNOCK_BACK_VEL_X = 600
const KNOCK_BACK_VEL_Y = 400
const KNOCK_BACK_FADE_RATE = 1250

const LIFETIME = 5
const DIE_ANIMATION_DURATION = 0.4

var lifetime_timestamp
var movement_pattern
var exploding = false
var die_timer
var dir_x

onready var animator = $"Animation/AnimationPlayer"
onready var gravity_movement = preload("res://Scripts/Movements/GravityMovement.gd").new(self, GRAVITY)

func _ready():
	animator.play("Blinking")

func initialize(dir_x):
	self.dir_x = dir_x
	movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(dir_x * SPEED_X, 0)
	lifetime_timestamp = OS.get_unix_time()

func _process(delta):
	if exploding:
		return

	gravity_movement.move(delta)
	move_and_collide(movement_pattern.movement(delta))

	if gravity_movement.is_landed || OS.get_unix_time() - lifetime_timestamp >= LIFETIME:
		explode()

func explode():
	exploding = true
	animator.play("Explode")
	die_timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(DIE_ANIMATION_DURATION, self, "queue_free")

func on_attack_hit(area):
	if !exploding && area.is_in_group("hero"):
		explode()

		var character = area.get_node("..")
		character.damaged(DAMAGE)
		character.knocked_back(dir_x * KNOCK_BACK_VEL_X, -KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)