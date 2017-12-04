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

const FADEOUT_DURATION = 0.3

var traveling = false
var lifetime_timestamp
var fade_out_timer = null
var fading = false

var cd_timer = preload("res://Scripts/Utils/CountdownTimer.gd")

onready var animator = get_node("AnimationPlayer")

onready var movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(0, 0)

func _ready():
	lifetime_timestamp = OS.get_unix_time()
	set_process(true)

	animator.play("Anim")

func _process(delta):
	enlarge(delta)

	if traveling:
		set_global_pos(movement_pattern.movement(get_global_pos(), delta))

	if OS.get_unix_time() - lifetime_timestamp >= LIFETIME:
		fade_out_and_queue_free()

func enlarge(delta):
	set_scale(get_scale() + Vector2(1.0, 1.0) * ENLARGE_RATE * delta)

func start_travel(target_pos):
	var dir = (target_pos - get_global_pos()).normalized()
	movement_pattern.dx = dir.x * SPEED
	movement_pattern.dy = dir.y * SPEED

	traveling = true

func on_attack_hit(area):
	if area.is_in_group("player_collider"):
		var character = area.get_node("..")
		character.damaged_over_time(TIME_PER_TICK, TOTAL_TICKS, DAMAGE_PER_TICK)
		character.knocked_back(sign(movement_pattern.dx) * KNOCK_BACK_VEL_X, sign(movement_pattern.dy) * KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)

		fade_out_and_queue_free()

func fade_out_and_queue_free():
	if fading:
		return

	fading = true
	animator.play("Fade")

	fade_out_timer = cd_timer.new(FADEOUT_DURATION, self, "queue_free")