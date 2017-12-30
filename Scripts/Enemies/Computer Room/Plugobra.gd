extends Node2D

# Plugobra AI:
# 1. Rise from the ground
# 2. Scan shot players (do little damage).
# 3. Wait.
# 4. Repeat 2.
# ===
# Cannot be stunned.

enum { NONE, RISE, STILL, LASER }

const MAX_HEALTH = 100

const ACTIVATE_RANGE = 2000

# Attack.
const DAMAGE = 10
const LASER_SHOW_DURATION = 0.2
const LASER_INTERVAL = 2.0

# Movement.
const RISE_LENGTH = 300
const RISE_SPEED_Y = 100

# Animation.
const DIE_ANIMATION_DURATION = 0.7

# Laser.
const LASER_THICKNESS = 5
const LASER_COLOR = Color(1, 0, 0)

var status_timer = null

onready var laser_pos_left = get_node("Laser Pos Left")
onready var laser_pos_right = get_node("Laser Pos Right")
onready var drawing_node = get_node("Drawing")

onready var rise_to_pos_y = get_global_pos().y - RISE_LENGTH

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)
onready var movement_type = ec.straight_line_movement.new(0, -RISE_SPEED_Y)

func activate():
	set_process(true)
	get_node("Animation/Damage Area").add_to_group("enemy_collider")
	ec.change_status(RISE)

func _process(delta):
	if ec.not_hurt_dying_stunned():
		if ec.status == RISE:
			rise(delta)
		elif ec.status == STILL:
			still()
		elif ec.status == LASER:
			shoot_laser()

func change_status(to_status):
	ec.change_status(to_status)

func rise(delta):
	ec.play_animation("Wiggle")
	
	set_global_pos(movement_type.movement(get_global_pos(), delta))

	if get_global_pos().y <= rise_to_pos_y:
		ec.change_status(LASER)

func still():
	ec.play_animation("Wiggle")

	if status_timer == null:
		drawing_node.clear_all()
		status_timer = ec.cd_timer.new(LASER_INTERVAL, self, "change_status", LASER)

func shoot_laser():
	ec.play_animation("Still")
	ec.change_status(NONE)

	var attack_target = ec.target_detect.get_nearest(self, ec.char_average_pos.characters)
	var left_from = laser_pos_left.get_global_pos() - get_global_pos()
	var right_from = laser_pos_right.get_global_pos() - get_global_pos()
	var to = left_from + attack_target.get_global_pos() - laser_pos_left.get_global_pos()
	var left_laser_line = {
		from_pos = left_from,
		to_pos = to,
		color = LASER_COLOR,
		width = LASER_THICKNESS
	}
	var right_laser_line = {
		from_pos = right_from,
		to_pos = to,
		color = LASER_COLOR,
		width = LASER_THICKNESS
	}
	drawing_node.add_line(left_laser_line)
	drawing_node.add_line(right_laser_line)
	attack_target.damaged(DAMAGE)

	status_timer = ec.cd_timer.new(LASER_SHOW_DURATION, self, "change_status", STILL)

func damaged(val):
	ec.damaged(val)

func resume_from_damaged():
	ec.resume_from_damaged()

func damaged_over_time(time_per_tick, total_ticks, damage_per_tick):
	ec.damaged_over_time(time_per_tick, total_ticks, damage_per_tick)

func stunned(duration):
	ec.display_immune_text()

func healed(val):
	ec.healed(val)

func healed_over_time(time_per_tick, total_ticks, heal_per_tick):
	ec.healed_over_time(time_per_tick, total_ticks, heal_per_tick)

func die():
	ec.die()
	status_timer = ec.cd_timer.new(DIE_ANIMATION_DURATION, self, "queue_free")