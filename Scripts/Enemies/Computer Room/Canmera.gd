extends Node2D

# Canmera AI
# 1. Aim to a random angle.
# 2. Countdown.
# 3. Shoot Canmera missle.
# 4. Repeat 1.
# ===
# When hurt or stunned, go to 1.
signal defeated

enum { NONE, AIM, COUNTDOWN, SHOOT }

export(int) var activate_range_x = 3000
export(int) var activate_range_y = 1000

const MAX_HEALTH = 250

# Rotation.
const ROTATE_SPEED_MIN = 30
const ROTATE_SPEED_MAX = 50
const AIM_ANGLE_MAX = 20.0
const AIM_ANGLE_MIN = -20.0

# Animation.
const DIE_ANIMATION_DURATION = 0.5
const COUNTDOWN_ANIMATION_DURATION = 3.0
const SHOOT_DURATION = 0.5

var status_timer = null
var die_timer = null
var curr_target_angle = null
var curr_speed = null

onready var body_node = $"Animation/Stand Remote Transform/Body"

# Missle.
var missle = preload("res://Scenes/Enemies/Computer Room/Canmera Missle.tscn")
onready var missle_spawn_pos = body_node.get_node("Missle Shoot Pos")
onready var spawn_node = $".."

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)

func activate():
	set_process(true)
	ec.change_status(AIM)
	$"Animation/Damage Area".add_to_group("enemy")

func _process(delta):
	if ec.not_hurt_dying_stunned():
		match ec.status:
			AIM:
				aim_and_rotate(delta)
			COUNTDOWN:
				start_countdown()
			SHOOT:
				shoot_missle()

func change_status(to_status):
	ec.change_status(to_status)

func aim_and_rotate(delta):
	ec.play_animation("Still")
	if curr_target_angle == null:
		# New aim.
		curr_target_angle = deg2rad(ec.rng.randf_range(AIM_ANGLE_MIN, AIM_ANGLE_MAX))
		var dir = curr_target_angle - body_node.rotation
		curr_speed = dir * deg2rad(ec.rng.randf_range(ROTATE_SPEED_MIN, ROTATE_SPEED_MAX))
	
	if aim_ended():
		curr_target_angle = null
		curr_speed = null
		ec.change_status(COUNTDOWN)
	else:
		body_node.rotation += curr_speed * delta

func aim_ended():
	var dir = sign(curr_speed)
	return dir == 1 && body_node.rotation >= curr_target_angle || dir == -1 && body_node.rotation <= curr_target_angle

func start_countdown():
	ec.play_animation("Count Down")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(COUNTDOWN_ANIMATION_DURATION, self, "change_status", SHOOT)

func shoot_missle():
	ec.change_status(NONE)
	spawn_missle()
	status_timer = ec.cd_timer.new(SHOOT_DURATION, self, "change_status", AIM)

func spawn_missle():
	var rotate_radian = body_node.rotation
	var dx = -cos(rotate_radian)
	var dy = sin(rotate_radian)

	var new_missle = missle.instance()
	new_missle.initialize(dx, dy)
	spawn_node.add_child(new_missle)
	new_missle.global_position = missle_spawn_pos.global_position

func damaged(val):
	ec.change_status(AIM)
	ec.damaged(val)

func resume_from_damaged():
	ec.resume_from_damaged()

func stunned(duration):
	ec.change_status(AIM)
	ec.stunned(duration)

func resume_from_stunned():
	ec.resume_from_stunned()

func healed(val):
	ec.healed(val)

func knocked_back(vel_x, vel_y, fade_rate):
	return

func slowed(multiplier, duration):
	return

func die():
	ec.die()
	emit_signal("defeated")
	die_timer = ec.cd_timer.new(DIE_ANIMATION_DURATION, self, "queue_free")