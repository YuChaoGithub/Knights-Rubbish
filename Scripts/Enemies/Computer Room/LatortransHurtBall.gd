extends Node2D

const SPEED = 700

const DAMAGE = 80
const KNOCK_BACK_VEL_X = 400
const KNOCK_BACK_VEL_Y = 400
const KNOCK_BACK_FADE_RATE = 800

const LIFETIME = 6

var lifetime_timestamp
var movement_pattern

func _ready():
	get_node("Animation/AnimationPlayer").play("Animate")

func initialize(dir):
	movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(dir.x * SPEED, dir.y * SPEED)
	lifetime_timestamp = OS.get_unix_time()
	set_process(true)

func _process(delta):
	set_pos(movement_pattern.movement(get_pos(), delta))

	if OS.get_unix_time() - lifetime_timestamp >= LIFETIME:
		queue_free()

func on_attack_hit(area):
	if area.is_in_group("player_collider"):
		var character = area.get_node("..")
		character.damaged(DAMAGE)
		character.knocked_back(-KNOCK_BACK_VEL_X, -KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)

		queue_free()