extends Node2D

const SPEED = 800

const DAMAGE_PER_TICK = 20
const TIME_PER_TICK = 1.0
const TOTAL_TICKS = 4
const KNOCK_BACK_VEL_X = 200
const KNOCK_BACK_VEL_Y = 200
const KNOCK_BACK_FADE_RATE = 400

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
		var character = area.get_node("..")
		
		# Damage over time.
		var dot = preload("res://Scenes/Utils/Change Health OT.tscn").instance()
		character.add_child(dot)
		dot.initialize(-DAMAGE_PER_TICK, TIME_PER_TICK, TOTAL_TICKS)
		
		character.show_ignited_particles(TIME_PER_TICK * TOTAL_TICKS)
		character.knocked_back(-KNOCK_BACK_VEL_X, -KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)

		queue_free()