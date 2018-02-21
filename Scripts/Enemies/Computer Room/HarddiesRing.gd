extends Node2D

# 1. Rotate to the angel aligning the movement.
# 2. Move straight to the target position.

const SPEED = 2000
const LIFETIME = 5

const DAMAGE = 60
const KNOCK_BACK_VEL_X = 500
const KNOCK_BACK_VEL_Y = 300
const KNOCK_BACK_FADE_RATE = 1200

var lifetime_timestamp

var movement_pattern

func initialize(start_pos, end_pos):
	var distance = float(start_pos.distance_to(end_pos))
	var dx = float(end_pos.x - start_pos.x) / distance
	var dy = float(end_pos.y - start_pos.y) / distance

	rotation = PI - acos(dx)

	movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(dx * SPEED, dy * SPEED)

	lifetime_timestamp = OS.get_unix_time()

func _process(delta):
	global_position += movement_pattern.movement(delta)

	if OS.get_unix_time() - lifetime_timestamp >= LIFETIME:
		queue_free()

func on_attack_hit(area):
	if area.is_in_group("hero"):
		var character = area.get_node("..")
		character.damaged(DAMAGE)
		character.knocked_back(KNOCK_BACK_VEL_X, KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)

		queue_free()