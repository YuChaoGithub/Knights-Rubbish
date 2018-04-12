extends KinematicBody2D

# ASCII Gunner AI:
# 1. Roam.
# 2. When the player is in range, shoot.
# 3. Repat 1.
# ===
# Play hurt animation only when roaming.
# When stunned, go to 1.

export(int) var activate_range_x = 1500
export(int) var activate_range_y = 10000

enum { NONE, ROAM, ATTACK }

const MAX_HEALTH = 100

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
var facing = -1

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)

func activate():
	ec.init_gravity_movement(GRAVITY)
	set_process(true)
	ec.change_status(ROAM)
	$"Animation/Damage Area".add_to_group("enemy")

func _process(delta):
	if ec.not_hurt_dying_stunned():
		match ec.status:
			ROAM:
				roam(delta)
			ATTACK:
				attack()

	ec.perform_gravity_movement(delta)
	ec.perform_knock_back_movement(delta)

func change_status(to_status):
	ec.change_status(to_status)

func roam(delta):
	ec.play_animation("Walk")
	
	if ec.random_movement == null:
		ec.init_random_movement("movement_not_ended", "movement_ended", SPEED_X, 0, true, RANDOM_MOVEMENT_STEPS, RANDOM_MOVEMENT_STEPS, RANDOM_MOVEMENT_MIN_TIME_PER_STEP, RANDOM_MOVEMENT_MAX_TIME_PER_STEP)

	ec.perform_random_movement(delta)

	# Target detection timer.
	if target_detect_timer == null:
		target_detect_timer = ec.cd_timer.new(TARGET_DETECT_INTERVAL, self, "check_target_in_range")
	
func movement_not_ended(movement_dir):
	facing = movement_dir
	ec.turn_sprites_x(facing)

func movement_ended():
	return

func check_target_in_range():
	target_detect_timer = null
	
	var nearest_target = ec.target_detect.get_nearest(self, ec.hero_manager.heroes)
	if abs(global_position.x - nearest_target.global_position.x) <= ATTACK_RANGE_X && abs(global_position.y - nearest_target.global_position.y) <= ATTACK_RANGE_Y:
		facing = sign(nearest_target.global_position.x - global_position.x)
		ec.turn_sprites_x(facing)
		ec.change_status(ATTACK)

func attack():
	ec.play_animation("Shoot")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(SHOOT_ANIMATION_DURATION, self, "change_status", ROAM)

func on_attack_hit(area):
	if area.is_in_group("hero"):
		var character = area.get_node("..")
		character.damaged(DAMAGE)
		character.knocked_back(facing * KNOCK_BACK_VEL_X, -KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)

func damaged(val):
	ec.damaged(val, ec.animator.current_animation == "Walk")
	
func resume_from_damaged():
	ec.resume_from_damaged()

func stunned(duration):
	ec.change_status(ROAM)
	ec.stunned(duration)

func resume_from_stunned():
	ec.resume_from_stunned()

func slowed(multiplier, duration):
	ec.slowed(multiplier, duration)

func slowed_recover(label):
	ec.slowed_recover(label)

func knocked_back(vel_x, vel_y, fade_rate):
	ec.knocked_back(vel_x, vel_y, fade_rate)

func healed(val):
	ec.healed(val)

func die():
	ec.die()
	status_timer = ec.cd_timer.new(DIE_ANIMATION_DURATION, self, "queue_free")