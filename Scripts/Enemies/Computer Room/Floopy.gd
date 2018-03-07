extends KinematicBody2D

# Floopy AI:
# 1. Run in range of the characters.
# 2. Punch.
# 3. Jump and flee. (Kiting)
# 4. Repeat 1.
# ===
# When hurt or stunned, go to 3.

signal defeated

enum { NONE, MOVE, PUNCH, INIT_FLEE, FLEE }

export(int) var activate_range_x = 1500
export(int) var activate_range_y = 1500

const MAX_HEALTH = 150

# Attack.
const ATTACK_RANGE_X = 150
const ATTACK_RANGE_Y = 100
const DAMAGE = 15
const KNOCK_BACK_VEL_X = 800
const KNOCK_BACK_FADE_RATE = 1400
const KNOCK_BACK_VEL_Y = 0
const STUN_DURATION = 0.75

# Movement.
const SPEED_X = 300
const FLEE_SPEED_X = 600
const GRAVITY = 600
const TURN_STAGGER_MIN_DELAY = 0.5
const TURN_STAGGER_MAX_DELAY = 2.0
const FLEE_DURATION_MIN = 0.75
const FLEE_DURATION_MAX = 1.5
const FLEE_JUMP_SPEED = 450

# Animation.
const PUNCH_ANIMATION_DURATION = 0.5
const DIE_ANIMATION_DURATION = 0.8

var attack_hit = false
var status_timer = null
var turn_stagger_timer = null
var attack_target = null
var facing = -1

# 50% it will be a green floopy.
var green_body_texture = preload("res://Graphics/Enemies/Computer Room/Floopy/green floppy.png")

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)

func _ready():
	if ec.rng.randsign() == 1:
		$"Animation/Body".set_texture(green_body_texture)

func activate():
	ec.init_gravity_movement(GRAVITY)
	ec.init_straight_line_movement(facing * SPEED_X, 0)
	
	set_process(true)
	ec.change_status(MOVE)
	$"Animation/Damage Area".add_to_group("enemy")

func _process(delta):
	if ec.not_hurt_dying_stunned():
		match ec.status:
			MOVE:
				apply_movement(delta)
			PUNCH:
				punch()
			INIT_FLEE:
				init_flee()
			FLEE:
				flee(delta)

	ec.perform_gravity_movement(delta)
	ec.perform_knock_back_movement(delta)

func change_status(to_status):
	ec.change_status(to_status)

func apply_movement(delta):
	ec.play_animation("Walk")

	if attack_target == null:
		ec.straight_line_movement.dx = facing * SPEED_X
		attack_target = ec.target_detect.get_nearest(self, ec.char_average_pos.characters)

	var target_pos = attack_target.global_position

	if target_pos.x < global_position.x && facing > 0:
		# Turn left, staggered.
		if turn_stagger_timer == null:
			turn_stagger_timer = ec.cd_timer.new(ec.rng.randf_range(TURN_STAGGER_MIN_DELAY, TURN_STAGGER_MAX_DELAY), self, "turn_and_set_stagger_timer_to_null")
			
	elif target_pos.x > global_position.x && facing < 0:
		# Turn right, staggered.
		if turn_stagger_timer == null:
			turn_stagger_timer = ec.cd_timer.new(ec.rng.randf_range(TURN_STAGGER_MIN_DELAY, TURN_STAGGER_MAX_DELAY), self, "turn_and_set_stagger_timer_to_null")


	ec.perform_straight_line_movement(delta)

	if in_attack_range():
		attack_target = null
		ec.change_status(PUNCH)

func turn_and_set_stagger_timer_to_null():
	facing = -facing
	ec.turn_sprites_x(facing)
	ec.straight_line_movement.dx = facing * SPEED_X
	turn_stagger_timer = null

func in_attack_range():
	var target_pos = attack_target.global_position
	return abs(target_pos.x - global_position.x) <= ATTACK_RANGE_X && abs(target_pos.y - global_position.y) <= ATTACK_RANGE_Y

func punch():
	ec.play_animation("Punch")
	cancel_stagger_turn_timer()
	attack_hit = false

	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(PUNCH_ANIMATION_DURATION, self, "change_status", INIT_FLEE)

func on_attack_hit(area):
	if !attack_hit && area.is_in_group("hero"):
		var character = area.get_node("..")
		character.damaged(DAMAGE)
		character.stunned(STUN_DURATION)
		character.knocked_back(facing * KNOCK_BACK_VEL_X, KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)

		attack_hit = true

func cancel_stagger_turn_timer():
	if turn_stagger_timer != null:
		turn_stagger_timer.destroy_timer()
		turn_stagger_timer = null

func init_flee():
	facing = -facing
	ec.turn_sprites_x(facing)
	ec.straight_line_movement.dx = facing * FLEE_SPEED_X
	
	# ANCIENT MYSTERY: So it turns out that this line of code makes Floopy jumps SOMETIMES and not ALWAYS.
	# I'll keep it here since random jumping actually works pretty nice here.
	# Got to get back here and figure out why this random jumping occurs some time later though.
	ec.gravity_movement.dy = -FLEE_JUMP_SPEED

	ec.change_status(FLEE)
	
	status_timer = ec.cd_timer.new(ec.rng.randf_range(FLEE_DURATION_MIN, FLEE_DURATION_MAX), self, "change_status", MOVE)

func flee(delta):
	ec.play_animation("Walk")
	ec.perform_straight_line_movement(delta)
	# State transition in written in init_flee().

func damaged(val):
	ec.change_status(MOVE)
	ec.damaged(val)

func resume_from_damaged():
	ec.resume_from_damaged()

func stunned(duration):
	ec.change_status(MOVE)
	ec.stunned(duration)

func resume_from_stunned():
	ec.resume_from_stunned()

func healed(val):
	ec.healed(val)

func knocked_back(vel_x, vel_y, fade_rate):
	ec.knocked_back(vel_x, vel_y, fade_rate)

func slowed(multiplier, duration):
	ec.slowed(multiplier, duration)

func slowed_recover(label):
	ec.slowed_recover(label)

func die():
	emit_signal("defeated")
	ec.die()
	status_timer = ec.cd_timer.new(DIE_ANIMATION_DURATION, self, "queue_free")