extends KinematicBody2D

# ASCII Gunner AI:
# 1. Roam.
# 2. When the player is in range, shoot.
# 3. Repat 1.
# ===
# Play hurt animation only when roaming.
# When stunned, go to 1.

enum { NONE, ROAM, ATTACK }

const MAX_HEALTH = 100

const ACTIVATE_RANGE = 1500

# Attack.
const ATTACK_RANGE_X = 750
const ATTACK_RANGE_Y = 150
const DAMAGE = 3
const KNOCK_BACK_VEL_X = 50
const KNOCK_BACK_VEL_Y = 50
const KNOCK_BACK_FADE_RATE = 150

# Movement.
const SPEED_X = 300
const GRAVITY = 600
const RANDOM_MOVEMENT_STEPS = 5
const RANDOM_MOVEMENT_MIN_TIME_PER_STEP = 1.0
const RANDOM_MOVEMENT_MAX_TIME_PER_STEP = 2.0

# Animation.
const DIE_ANIMATION_DURATION = 0.5
const SHOOT_ANIMATION_DURATION = 3.0
const TARGET_DETECT_INTERVAL = 1.0

var status_timer = null
var target_detect_timer = null
var curr_rand_movement = null
var facing = -1

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)
onready var gravity_movement = ec.gravity_movement.new(self, GRAVITY)

func activate():
	set_process(true)
	ec.change_status(ROAM)
	get_node("Animation/Damage Area").add_to_group("enemy_collider")

func _process(delta):
	if ec.not_hurt_dying_stunned():
		if ec.status == ROAM:
			roam(delta)
		elif ec.status == ATTACK:
			attack()

	apply_gravity(delta)

func change_status(to_status):
	ec.change_status(to_status)

func apply_gravity(delta):
	move_to(gravity_movement.movement(get_global_pos(), delta))

func roam(delta):
	ec.play_animation("Walk")
	
	if curr_rand_movement == null:
		curr_rand_movement = ec.random_movement.new(SPEED_X, 0, true, RANDOM_MOVEMENT_STEPS, RANDOM_MOVEMENT_STEPS, RANDOM_MOVEMENT_MIN_TIME_PER_STEP, RANDOM_MOVEMENT_MAX_TIME_PER_STEP)

	if curr_rand_movement.movement_ended():
		curr_rand_movement = null
	else:
		var final_pos = curr_rand_movement.movement(get_global_pos(), delta)
		
		if final_pos.x < get_global_pos().x:
			facing = -1
		elif final_pos.x > get_global_pos().x:
			facing = 1
		ec.turn_sprites_x(facing)

		move_to(final_pos)

	# Target detection timer.
	if target_detect_timer == null:
		target_detect_timer = ec.cd_timer.new(TARGET_DETECT_INTERVAL, self, "check_target_in_range")
	
func check_target_in_range():
	target_detect_timer = null
	
	var nearest_target = ec.target_detect.get_nearest(self, ec.char_average_pos.characters)
	if abs(get_global_pos().x - nearest_target.get_global_pos().x) <= ATTACK_RANGE_X && abs(get_global_pos().y - nearest_target.get_global_pos().y) <= ATTACK_RANGE_Y:
		facing = sign(nearest_target.get_global_pos().x - get_global_pos().x)
		ec.turn_sprites_x(facing)
		ec.change_status(ATTACK)

func attack():
	ec.play_animation("Shoot")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(SHOOT_ANIMATION_DURATION, self, "change_status", ROAM)

func on_attack_hit(area):
	if area.is_in_group("player_collider"):
		var character = area.get_node("..")
		character.damaged(DAMAGE)
		character.knocked_back(facing * KNOCK_BACK_VEL_X, -KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)

func damaged(val):
	ec.damaged(val, ec.animator.get_current_animation() == "Walk")
	
func resume_from_damaged():
	ec.resume_from_damaged()

func stunned(duration):
	ec.change_status(ROAM)
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