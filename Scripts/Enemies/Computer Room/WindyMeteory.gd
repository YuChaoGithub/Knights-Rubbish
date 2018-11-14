extends Node2D

# Windy Meteory AI:
# 1. Wait until a character gets close enough.
# 2. Drops down.

const SPEED_Y = 1700

const DAMAGE = 50
const KNOCK_BACK_VEL_X = 800
const KNOCK_BACK_VEL_Y = 0
const KNOCK_BACK_FADE_RATE = 1200

const APPEAR_RANGE = 700
const DROP_RANGE = 200

const LIFETIME = 3.0

var timestamp = 0.0
var start_falling = false
var activated = false

var target_detect = preload("res://Scripts/Algorithms/TargetDetection.gd")

onready var hero_manager = $"../../HeroManager"
onready var movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(0, SPEED_Y)
onready var animator = $"Animation/AnimationPlayer"

func _ready():
	animator.play("Still")

func _process(delta):
	if start_falling:
		# Movement.
		global_position += movement_pattern.movement(delta)

		# Lifetime.
		timestamp += delta
		if timestamp > LIFETIME:
			queue_free()
	else:
		var target = target_detect.get_nearest(self, hero_manager.heroes)
		
		var distance_x = abs(target.global_position.x - global_position.x)

		# Activate.
		if !activated && distance_x < APPEAR_RANGE:
			animator.play("Appear")
			activated = true
		elif distance_x < DROP_RANGE && !target.status.fallen_off:
			animator.play("Dropping")
			start_falling = true

func on_attack_hit(area):
	if area.is_in_group("hero"):
		var character = area.get_node("..")
		character.damaged(DAMAGE)
		character.knocked_back(sign(character.global_position.x - global_position.x) * KNOCK_BACK_VEL_X, KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)