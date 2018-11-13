extends Node2D

# 1. Wait for some seconds.
# 2. Drops down from the ceiling.
# 3. Shoots laser to the nearest character.
# 4. Climbs Up.
# 5. Repeat 1.
# ===
# Cannot be stunned.

signal defeated

enum { NONE, WAITING, DROP, TURN_ON, LASER, TURN_OFF, CLIMB }

export(int) var activate_range_x = 1500
export(int) var activate_range_y = 1500
export(int) var drop_destination_y

const MAX_HEALTH = 150

# Attack.
const ATTACK_COUNT = 4
const DAMAGE = 2
const LASER_SHOW_DURATION = 0.1
const LASER_HIDE_DURATION = 0.2

# Movement.
const WAIT_MIN_TIME = 1.0
const WAIT_MAX_TIME = 3.0
const DROP_SPEED = 200
const CLIMB_SPEED = -300
const ATTACK_RANGE_X = 400
const DROPPING_TO_CHAR_OFFSET_Y = 150

# Animation.
const TURN_ON_ANIMATION_DURATION = 0.5
const TURN_OFF_ANIMATION_DURATION = 0.5
const DIE_ANIMATION_DURATION = 0.3

# Silk and Laser.
const ATTACHED_SILK_THICKNESS = 7
const SILK_COLOR = Color(0, 0, 0)
const LASER_THICKNESS = 10
const LASER_COLOR = Color(1, 0, 0)

var attack_target = null
var attack_timer = null
var status_timer = null
var die_timer = null
var laser_count = 0

onready var laserlight = $"LaserLight"

onready var original_pos_y = self.position.y
onready var silk_attach_spot = $"Silk Attach Pos"
onready var silk_attach_spot_original_pos = silk_attach_spot.global_position
onready var laser_pos = $"Laser Pos"
onready var drawing_node = $Drawing

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)

onready var laser_audio = $Audio/Laser

func activate():
	ec.init_straight_line_movement(0, 0)
	set_process(true)
	$"Animation/Damage Area".add_to_group("enemy")
	ec.change_status(WAITING)

func _process(delta):
	update()

	if ec.not_hurt_dying_stunned():
		match ec.status:
			WAITING:
				wait_for_some_time()
			DROP:
				drop_down(delta)
			TURN_ON:
				play_turn_on_animation()
			LASER:
				shoot_laser()
			TURN_OFF:
				play_turn_off_animation()
			CLIMB:
				climb_up(delta)

func _draw():
	# Silk.
	var from_pos = silk_attach_spot.global_position - global_position
	var to_pos = Vector2(from_pos.x, from_pos.y - (silk_attach_spot.global_position.y - silk_attach_spot_original_pos.y))
	draw_line(from_pos, to_pos, SILK_COLOR, ATTACHED_SILK_THICKNESS)

	# Laser line is drawn in the drawing node so that it appears at the front.

func change_status(to_status):
	ec.change_status(to_status)

func wait_for_some_time():
	ec.play_animation("Still")
	ec.change_status(NONE)
	var wait_time = ec.rng.randf_range(WAIT_MIN_TIME, WAIT_MAX_TIME)
	status_timer = ec.cd_timer.new(wait_time, self, "change_status", DROP)

func drop_down(delta):
	ec.play_animation("Swing")
	ec.straight_line_movement.set_velocity(0, DROP_SPEED)
	ec.perform_straight_line_movement(delta)

	if global_position.y > drop_destination_y:
		ec.change_status(TURN_ON)

func play_turn_on_animation():
	ec.play_animation("Turn On")
	ec.change_status(NONE)
	laser_count = 0
	status_timer = ec.cd_timer.new(TURN_ON_ANIMATION_DURATION, self, "change_status", LASER)

func shoot_laser():
	status_timer = null
	ec.change_status(NONE)
	attack_timer = ec.cd_timer.new(LASER_SHOW_DURATION, self, "laser_hit")

func laser_hit():
	attack_target = ec.target_detect.get_nearest(self, ec.hero_manager.heroes)

	var from = laser_pos.global_position - global_position
	var to = from + attack_target.global_position - laser_pos.global_position
	var laser_line = {
		from_pos = from,
		to_pos = to,
		color = LASER_COLOR,
		width = LASER_THICKNESS
	}
	laser_audio.play()
	laserlight.global_position = attack_target.global_position
	laserlight.enabled = true
	drawing_node.add_line(laser_line)
	attack_target.damaged(DAMAGE, false)
	laser_count += 1
	attack_timer = ec.cd_timer.new(LASER_SHOW_DURATION, self, "laser_off")

func laser_off():
	drawing_node.clear_all()
	laserlight.enabled = false

	if laser_count < ATTACK_COUNT:
		attack_timer = ec.cd_timer.new(LASER_HIDE_DURATION, self, "shoot_laser")
	else:
		cancel_attack_sequence()
		status_timer = ec.cd_timer.new(LASER_HIDE_DURATION, self, "play_turn_off_animation")

func play_turn_off_animation():
	cancel_attack_sequence()
	ec.play_animation("Turn Off")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(TURN_OFF_ANIMATION_DURATION, self, "change_status", CLIMB)

func cancel_attack_sequence():
	if attack_timer != null:
		attack_timer.destroy_timer()
		attack_timer = null

func climb_up(delta):
	ec.play_animation("Swing")
	ec.straight_line_movement.set_velocity(0, CLIMB_SPEED)
	ec.perform_straight_line_movement(delta)

	if position.y <= original_pos_y:
		ec.change_status(WAITING)

func damaged(val):
	ec.damaged(val)

func resume_from_damaged():
	ec.resume_from_damaged()

func stunned(duration):
	pass

func slowed(multiplier, duration):
	return

func knocked_back(vel_x, vel_y, fade_rate):
	return

func die():
	ec.die()
	emit_signal("defeated")
	cancel_attack_sequence()
	die_timer = ec.cd_timer.new(DIE_ANIMATION_DURATION, self, "queue_free")

func healed(val):
	ec.healed(val)