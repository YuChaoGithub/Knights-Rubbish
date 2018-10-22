extends Node2D

const SPEED = 400

const SLOW_RATE = 0.5
const DAMAGE = 10
const SLOW_DURATION = 4.0

const LIFETIME = 15

var lifetime_timestamp
var movement_pattern

func _ready():
	$"Animation/AnimationPlayer".play("Animate")

func initialize(dir):
	movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(dir.x * SPEED, dir.y * SPEED)
	lifetime_timestamp = OS.get_unix_time()

func _process(delta):
	position += movement_pattern.movement(delta)

	if OS.get_unix_time() - lifetime_timestamp >= LIFETIME:
		queue_free()

func on_attack_hit(area):
	if area.is_in_group("hero"):
		var args = {
			multiplier = SLOW_RATE,
			duration = SLOW_DURATION
		}
		var hero = area.get_node("..")
		hero.speed_changed(args)
		hero.damaged(DAMAGE)

		set_process(false)
		# Will be freed by the animation.
		$"Animation/AnimationPlayer".play("Explode")