extends KinematicBody2D

# Floopy AI:
# 1. Run in range of the characters.
# 2. Punch.
# 3. Jump and flee. (Kiting)
# 4. Repeat 1.
# ===
# When hurt or stunned, go to 3.

enum { NONE, MOVE, PUNCH, INIT_FLEE, FLEE }

const MAX_HEALTH = 150

const ACTIVATE_RANGE = 1500

# Attack.
const ATTACK_RANGE_X = 150
const ATTACK_RANGE_Y = 100
const DAMAGE = 30
const KNOCK_BACK_VEL_X = 800
const KNOCK_BACK_FADE_RATE = 1400
const KNOCK_BACK_VEL_Y = 0
const STUN_DURATION = 1.25

# Movement.
const SPEED_X = 400
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
onready var movement_type = ec.straight_line_movement.new(facing * SPEED_X, 0)
onready var gravity_movement = ec.gravity_movement.new(self, GRAVITY)

func activate():
	if ec.rng.randsign() == 1:
		get_node("Animation/Body").set_texture(green_body_texture)
	set_process(true)
	ec.change_status(MOVE)
	get_node("Animation/Damage Area").add_to_group("enemy_collider")

func _process(delta):
	if ec.not_hurt_dying_stunned():
		if ec.status == MOVE:
			apply_movement(delta)
		elif ec.status == PUNCH:
			punch()
		elif ec.status == INIT_FLEE:
			init_flee()
		elif ec.status == FLEE:
			flee(delta)

	apply_gravity(delta)

func change_status(to_status):
	ec.change_status(to_status)

func apply_gravity(delta):
	move_to(gravity_movement.movement(get_global_pos(), delta))	

func apply_movement(delta):
	ec.play_animation("Walk")

	if attack_target == null:
		movement_type.dx = facing * SPEED_X
		attack_target = ec.target_detect.get_nearest(self, ec.char_average_pos.characters)

	var target_pos = attack_target.get_global_pos()

	if target_pos.x < get_global_pos().x && facing > 0:
		# Turn left, staggered.
		if turn_stagger_timer == null:
			turn_stagger_timer = ec.cd_timer.new(ec.rng.randf_range(TURN_STAGGER_MIN_DELAY, TURN_STAGGER_MAX_DELAY), self, "turn_and_set_stagger_timer_to_null")
			
	elif target_pos.x > get_global_pos().x && facing < 0:
		# Turn right, staggered.
		if turn_stagger_timer == null:
			turn_stagger_timer = ec.cd_timer.new(ec.rng.randf_range(TURN_STAGGER_MIN_DELAY, TURN_STAGGER_MAX_DELAY), self, "turn_and_set_stagger_timer_to_null")


	var final_pos = movement_type.movement(get_global_pos(), delta)
	move_to(final_pos)

	if in_attack_range():
		attack_target = null
		ec.change_status(PUNCH)

func turn_and_set_stagger_timer_to_null():
	facing = -facing
	ec.turn_sprites_x(facing)
	movement_type.dx = facing * SPEED_X
	turn_stagger_timer = null

func in_attack_range():
	var target_pos = attack_target.get_global_pos()
	return abs(target_pos.x - get_global_pos().x) <= ATTACK_RANGE_X && abs(target_pos.y - get_global_pos().y) <= ATTACK_RANGE_Y

func punch():
	ec.play_animation("Punch")
	cancel_stagger_turn_timer()
	attack_hit = false

	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(PUNCH_ANIMATION_DURATION, self, "change_status", INIT_FLEE)

func on_attack_hit(area):
	if !attack_hit && area.is_in_group("player_collider"):
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
	movement_type.dx = facing * FLEE_SPEED_X
	
	# ANCIENT MYSTERY: So it turns out that this line of code makes Floopy jumps SOMETIMES and not ALWAYS.
	# I'll keep it here since random jumping actually works pretty nice here.
	# Got to get back here and figure out why this random jumping occurs some time later though.
	gravity_movement.dy = -FLEE_JUMP_SPEED

	ec.change_status(FLEE)
	
	status_timer = ec.cd_timer.new(ec.rng.randf_range(FLEE_DURATION_MIN, FLEE_DURATION_MAX), self, "change_status", MOVE)

func flee(delta):
	ec.play_animation("Walk")
	move_to(movement_type.movement(get_global_pos(), delta))
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

func damaged_over_time(time_per_tick, total_ticks, damage_per_tick):
	ec.damaged_over_time(time_per_tick, total_ticks, damage_per_tick)

func healed(val):
	ec.healed(val)

func healed_over_time(time_per_tick, total_ticks, heal_per_tick):
	ec.healed_over_time(time_per_tick, total_ticks, heal_per_tick)

func die():
	ec.die()
	status_timer = ec.cd_timer.new(DIE_ANIMATION_DURATION, self, "queue_free")