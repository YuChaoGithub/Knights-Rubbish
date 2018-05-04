extends Node2D

const SPEED = 600

const STUN_DURATION = 5

const LIFETIME = 6

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
		area.get_node("..").stunned(STUN_DURATION)

		queue_free()