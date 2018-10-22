extends Node2D

const SPEED = 850

const CONFUSION_DURATION = 3.0
const DAMAGE = 10

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
		var hero = area.get_node("..")
		hero.confused(CONFUSION_DURATION)
		hero.damaged(DAMAGE)

		set_process(false)
		# Will be freed by the animation.
		$"Animation/AnimationPlayer".play("Explode")