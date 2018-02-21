extends Node2D

# Sonmera AI:
# 1. Wait for a certain interval.
# 2. Countdown from 3 to 1.
# 3. Capture a screenshot if none has been captured yet.
# 4. Flashlight activated (white screen).
# 5. Repeat 1.

enum { NONE, INACTIVE, WAIT, COUNTDOWN, CAPTURE, FLASHLIGHT }

export(int) var activate_range_x = 3000

const IDLE_INTERVAL_MIN = 2.0
const IDLE_INTERVAL_MAX = 5.0

# Animation.
const COUNTDOWN_DURATION = 3.3
const CAPTURE_SCREENSHOT_DURATION = 0.2
const FLASHLIGHT_DURATION = 0.4

var status = INACTIVE
var status_timer = null
var screen_captured = false

var cd_timer = preload("res://Scripts/Utils/CountdownTimer.gd")
var rng = preload("res://Scripts/Utils/RandomNumberGenerator.gd")

onready var animator = $"Animation/AnimationPlayer"
onready var flashlight_animator = $"Flashlight/AnimationPlayer"
onready var char_average_pos = $"../../../../Character Average Position"

func _ready():
	animator.play("Still")

func _process(delta):
	match status:
		INACTIVE:
			check_nearest_char()
		WAIT:
			wait_for_interval()
		COUNTDOWN:
			start_countdown()
		CAPTURE:
			capture_screenshot()
		FLASHLIGHT:
			activate_flashlight()

func change_status(to_status):
	status = to_status
	if status_timer != null:
		status_timer.destroy_timer()
		status_timer = null

func check_nearest_char():
	if char_average_pos.global_position.distance_squared_to(global_position) <= activate_range_x * activate_range_x:
		change_status(WAIT)

func wait_for_interval():
	animator.play("Still")
	flashlight_animator.play("Blank")

	change_status(NONE)
	status_timer = cd_timer.new(rng.randf_range(IDLE_INTERVAL_MIN, IDLE_INTERVAL_MAX), self, "change_status", COUNTDOWN)

func start_countdown():
	animator.play("Count Down")
	change_status(NONE)
	status_timer = cd_timer.new(COUNTDOWN_DURATION, self, "change_status", CAPTURE)

func capture_screenshot():
	# TODO: Capture Screenshot.
	if !screen_captured:
		print("Capture a screenshot")
		screen_captured = true

	change_status(NONE)
	status_timer = cd_timer.new(CAPTURE_SCREENSHOT_DURATION, self, "change_status", FLASHLIGHT)

func activate_flashlight():
	flashlight_animator.play("Flash")
	change_status(NONE)
	status_timer = cd_timer.new(FLASHLIGHT_DURATION, self, "change_status", WAIT)