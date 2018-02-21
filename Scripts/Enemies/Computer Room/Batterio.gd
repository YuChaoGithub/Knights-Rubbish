extends Node2D

# Batterio AI
# 1. Warning for 0.5 seconds.
# 2. Turn on for a certain duration.
# 3. Turn off for a certain duration. Repeat 1.

export(int) var activate_range_x = 3000
export(int) var activate_range_y = 1500

enum { NONE, INACTIVE, WARNING, TURN_ON, TURN_OFF }

export(float) var on_duration = 2.0
export(float) var off_duration = 2.0

const WARNING_DURATION = 0.5

const DAMAGE = 5
const DAMAGE_COLLIDER_ON_INTERVAL = 0.2
const DAMAGE_COLLIDER_OFF_INTERVAL = 0.1

var status = INACTIVE
var status_timer = null
var laser_timer = null

var cd_timer = preload("res://Scripts/Utils/CountdownTimer.gd")

onready var hero_layer = ProjectSettings.get_setting("layer_names/2d_physics/hero")

onready var animator = $AnimationPlayer
onready var attack_collider = $"Attack Area"
onready var char_average_pos = $"../../../../Character Average Position"

func _ready():
	animator.play("Still")

func _process(delta):
	match status:
		INACTIVE:
			check_for_active()
		WARNING:
			display_warning()
		TURN_ON:
			turn_laser_on()
		TURN_OFF:
			turn_laser_off()

func change_status(to_status):
	status = to_status
	if status_timer != null:
		status_timer.destroy_timer()
		status_timer = null

func check_for_active():
	if char_average_pos.in_range_of(global_position, activate_range_x, activate_range_y):
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
	attack_collider.set_collision_mask_bit(hero_layer, true)
	laser_timer = cd_timer.new(DAMAGE_COLLIDER_ON_INTERVAL, self, "attack_collider_off_sequence")

func attack_collider_off_sequence():
	attack_collider.set_collision_mask_bit(hero_layer, false)
	laser_timer = cd_timer.new(DAMAGE_COLLIDER_OFF_INTERVAL, self, "attack_collider_on_sequence")

func end_attack_collider_sequence():
	laser_timer.destroy_timer()
	laser_timer = null
	attack_collider.set_collision_mask_bit(hero_layer, false)

func on_attack_hit(area):
	if area.is_in_group("hero"):
		area.get_node("..").damaged(DAMAGE)