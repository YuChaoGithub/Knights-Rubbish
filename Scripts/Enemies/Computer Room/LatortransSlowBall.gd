extends Node2D

const SPEED = 400

const SLOW_RATE = 0.5
const SLOW_DURATION = 3.0

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
		area.get_node("..").speed_changed(SLOW_RATE, SLOW_DURATION)

		queue_free()