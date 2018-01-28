extends Node2D

# Batterio AI
# 1. Warning for 0.5 seconds.
# 2. Turn on for a certain duration.
# 3. Turn off for a certain duration. Repeat 1.

enum { NONE, INACTIVE, WARNING, TURN_ON, TURN_OFF }

export(float) var on_duration = 2.0
export(float) var off_duration = 2.0

const ACTIVATE_RANGE = 3000

const WARNING_DURATION = 0.5
const PLAYER_LAYER = 1

const DAMAGE = 5
const DAMAGE_COLLIDER_ON_INTERVAL = 0.2
const DAMAGE_COLLIDER_OFF_INTERVAL = 0.1

var status = INACTIVE
var status_timer = null
var laser_timer = null

var cd_timer = preload("res://Scripts/Utils/CountdownTimer.gd")

onready var animator = get_node("AnimationPlayer")
onready var attack_collider = get_node("Attack Area")
onready var char_average_pos = get_node("../../../../Character Average Position")

func _ready():
	animator.play("Still")
	set_process(true)

func _process(delta):
	if status == INACTIVE:
		check_for_active()
	elif status == WARNING:
		display_warning()
	elif status == TURN_ON:
		turn_laser_on()
	elif status == TURN_OFF:
		turn_laser_off()

func change_status(to_status):
	status = to_status
	if status_timer != null:
		status_timer.destroy_timer()
		status_timer = null

func check_for_active():
	if char_average_pos.get_global_pos().distance_squared_to(get_global_pos()) <= ACTIVATE_RANGE * ACTIVATE_RANGE:
		change_status(WARNING)

func display_warning():
	change_status(NONE)
	animator.play("Warning")
	status_timer = cd_timer.new(WARNING_DURATION, self, "change_status", TURN_ON)

func turn_laser_on():
	change_status(NONE)
	animator.play("Turn On")
	attack_collider_on_sequence()
	status_timer = cd_timer.new(on_duration, self, "change_status", TURN_OFF)

func turn_laser_off():
	change_status(NONE)
	animator.play("Turn Off")
	end_attack_collider_sequence()
	status_timer = cd_timer.new(off_duration, self, "change_status", WARNING)

func attack_collider_on_sequence():
	attack_collider.set_collision_mask(PLAYER_LAYER)
	laser_timer = cd_timer.new(DAMAGE_COLLIDER_ON_INTERVAL, self, "attack_collider_off_sequence")

func attack_collider_off_sequence():
	attack_collider.set_collision_mask(0)
	laser_timer = cd_timer.new(DAMAGE_COLLIDER_OFF_INTERVAL, self, "attack_collider_on_sequence")

func end_attack_collider_sequence():
	laser_timer.destroy_timer()
	laser_timer = null
	attack_collider.set_collision_mask(0)

func on_attack_hit(area):
	if area.is_in_group("player_collider"):
		area.get_node("..").damaged(DAMAGE)