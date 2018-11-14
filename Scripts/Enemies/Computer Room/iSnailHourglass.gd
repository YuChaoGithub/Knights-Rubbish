extends Node2D

const SPEED_X = 200

const DAMAGE = 20
const SLOW_RATE = 0.2
const SLOW_DURATION = 1.2

const LIFETIME = 20.0

var timestamp = 0.0

var movement_pattern

func _ready():
	$AnimationPlayer.play("Turn")

func initialize(dir_x):
	movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(dir_x * SPEED_X, 0)

func _process(delta):
	global_position += movement_pattern.movement(delta)

	timestamp += delta
	if timestamp > LIFETIME:
		queue_free()

func on_attack_hit(area):
	if area.is_in_group("hero"):
		var character = area.get_node("..")
		var args = {
			multiplier = SLOW_RATE,
			duration = SLOW_DURATION
		}
		character.damaged(DAMAGE)
		character.speed_changed(args)

		# Will be freed by the animation.
		set_process(false)
		$AnimationPlayer.play("Explode")