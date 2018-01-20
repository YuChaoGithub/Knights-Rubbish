extends Node2D

const SPEED_Y = 125
const SHOOT_DURATION = 3.0
const PAUSE_DURATION = 0.2
const INVISIBLE_DURATION = 8.0
const TO_SCALE = 0.25
const SCALE_SMOOTH = 1.0

var start_travel = false
var timer

var cd_timer = preload("res://Scripts/Utils/CountdownTimer.gd")
var ball = preload("res://Scenes/Power Ups/Traveling Ult Ball.tscn")

onready var spinner = get_node("Spinner")
onready var char_average_pos = get_node("../../../../Character Average Position")

func _process(delta):
	translate(Vector2(0, -SPEED_Y * delta))
	set_scale(Vector2(1.0, 1.0) * lerp(get_scale().x, TO_SCALE, delta * SCALE_SMOOTH))

func being_hit():
	if start_travel:
		return

	if spinner.hit_and_check_if_complete():
		start_travel = true
		set_process(true)
		timer = cd_timer.new(SHOOT_DURATION, self, "pause_in_air")

func pause_in_air():
	set_process(false)
	timer = cd_timer.new(PAUSE_DURATION, self, "spawn_ball_to_characters")

func spawn_ball_to_characters():
	spinner.shoot = true

	for character in char_average_pos.characters:
		var new_ball = ball.instance()
		get_node("..").add_child(new_ball)
		new_ball.set_global_pos(get_global_pos())
		new_ball.initialize(character)

	get_node("Ball").hide()
	timer = cd_timer.new(INVISIBLE_DURATION, self, "queue_free")

func damaged(val):
	being_hit()

func knocked_back(vel_x, vel_y, x_fade_rate):
	pass

func stunned(duration):
	pass

func slowed(mult, duration):
	pass