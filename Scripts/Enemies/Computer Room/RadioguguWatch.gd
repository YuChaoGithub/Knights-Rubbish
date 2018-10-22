extends Node2D

const SPEED = 2000
const LIFETIME = 2

const DAMAGE = 30
const SLOW_DURATION = 5
const SLOW_RATE = 0.5
const KNOCK_BACK_VEL_X = 150
const KNOCK_BACK_VEL_Y = 150
const KNOCK_BACK_FADE_RATE = 300

var lifetime_timestamp
var movement_pattern
var parent_node

func initialize(direction, node):
	parent_node = node
	movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(SPEED * direction.x, SPEED * direction.y)
	lifetime_timestamp = OS.get_unix_time()

func _process(delta):
	position += movement_pattern.movement(delta)

	if OS.get_unix_time() - lifetime_timestamp >= LIFETIME:
		free_watch()

func on_attack_hit(area):
	if area.is_in_group("hero"):
		var character = area.get_node("..")
		var args = {
			multiplier = SLOW_RATE,
			duration = SLOW_DURATION
		}

		character.damaged(DAMAGE)
		character.knocked_back(KNOCK_BACK_VEL_X, KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)
		character.speed_changed(args)

		parent_node.attack_target = character
		free_watch()

func free_watch():
	parent_node.curr_watch = null
	set_process(false)
	$AnimationPlayer.play("Explode")