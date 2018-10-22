extends Node2D

const SPEED = 60

const DAMAGE_PER_TICK = 10
const TIME_PER_TICK = 1
const TOTAL_TICKS = 4

const KNOCK_BACK_VEL_X = 500
const KNOCK_BACK_VEL_Y = 500
const KNOCK_BACK_FADE_RATE = 1000

const ENLARGE_RATE = 0.5
const LIFETIME = 11

var traveling = false
var lifetime_timestamp

var dot = preload("res://Scenes/Utils/Change Health OT.tscn")

onready var animator = $"AnimationPlayer"

onready var movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(0, 0)

func _ready():
	lifetime_timestamp = OS.get_unix_time()
	animator.play("Anim")

func _process(delta):
	enlarge(delta)

	if traveling:
		global_position += movement_pattern.movement(delta)

	if OS.get_unix_time() - lifetime_timestamp >= LIFETIME:
		set_process(false)
		animator.play("Fade")

func enlarge(delta):
	scale += Vector2(1.0, 1.0) * ENLARGE_RATE * delta

func start_travel(target_pos):
	var dir = (target_pos - global_position).normalized()
	movement_pattern.dx = dir.x * SPEED
	movement_pattern.dy = dir.y * SPEED

	traveling = true

func on_attack_hit(area):
	if area.is_in_group("hero"):
		var character = area.get_node("..")

		var damage_over_time = dot.instance()
		character.add_child(damage_over_time)
		damage_over_time.initialize(-DAMAGE_PER_TICK, TIME_PER_TICK, TOTAL_TICKS)

		character.show_ignited_particles(TIME_PER_TICK * TOTAL_TICKS)
		
		character.knocked_back(sign(movement_pattern.dx) * KNOCK_BACK_VEL_X, sign(movement_pattern.dy) * KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)

		explode()

func explode():
	set_process(false)
	animator.play("Explode")