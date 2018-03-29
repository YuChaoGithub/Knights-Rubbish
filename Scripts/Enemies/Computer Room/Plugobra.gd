extends Node2D

# Plugobra AI:
# 1. Rise from the ground
# 2. Scan shot players (do little damage).
# 3. Wait.
# 4. Repeat 2.
# ===
# Cannot be stunned.

enum { NONE, RISE, STILL, LASER }

export(int) var activate_range_x = 2000
export(int) var activate_range_y = 2000

const MAX_HEALTH = 100

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

onready var laser_pos_left = $"Laser Pos Left"
onready var laser_pos_right = $"Laser Pos Right"
onready var drawing_node = $"Drawing"

onready var rise_to_pos_y = global_position.y - RISE_LENGTH

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)

func activate():
	ec.init_straight_line_movement(0, -RISE_SPEED_Y)
	set_process(true)
	$"Animation/Damage Area".add_to_group("enemy")
	ec.change_status(RISE)

func _process(delta):
	if ec.not_hurt_dying_stunned():
		match ec.status:
			RISE:
				rise(delta)
			STILL:
				still()
			LASER:
				shoot_laser()

func change_status(to_status):
	ec.change_status(to_status)

func rise(delta):
	ec.play_animation("Wiggle")
	
	ec.perform_straight_line_movement(delta)

	if global_position.y <= rise_to_pos_y:
		ec.change_status(LASER)

func still():
	ec.play_animation("Wiggle")

	if status_timer == null:
		drawing_node.clear_all()
		status_timer = ec.cd_timer.new(LASER_INTERVAL, self, "change_status", LASER)

func shoot_laser():
	ec.play_animation("Still")
	ec.change_status(NONE)

	var attack_target = ec.target_detect.get_nearest(self, ec.hero_average_pos.characters)
	var left_from = laser_pos_left.global_position - global_position
	var right_from = laser_pos_right.global_position - global_position
	var to = left_from + attack_target.global_position - laser_pos_left.global_position
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

func stunned(duration):
	pass

func healed(val):
	ec.healed(val)

func slowed(multiplier, duration):
	return

func knocked_back(vel_x, vel_y, fade_rate):
	return

func die():
	ec.die()
	status_timer = ec.cd_timer.new(DIE_ANIMATION_DURATION, self, "queue_free")