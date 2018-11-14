extends KinematicBody2D

# Harddies AI:
# 1. Flies through the sky for a certain duration.
# 2. Turn to the side which the nearest character is facing.
# 3. Toss two rings to -150px and +150px or the farthest character.
# 4. Turn to stone and falls on the ground. Gain tons of HP.
# 5. Knocks back and damage characters on the way of falling.
# 6. Become impassible when landed on ground.
# ===
# Don't play hurt animation when tossing ring or stoned.
# Can't be stunned when FALLING, LANDED. Otherwise, go to FLY after stunned.

signal defeated

enum { NONE, FLY, TOSS_ANIM, TOSS, FALLING, LANDED }

export(int) var activate_range_x = 2000
export(int) var activate_range_y = 2000

export(int) var left_limit
export(int) var right_limit

const MAX_HEALTH = 150
const STONED_MAX_HEALTH = 600

# Attack.
const RING_SPAWN_OFFSET = 150
const DAMAGE = 66
const KNOCK_BACK_VEL_X = 1000
const KNOCK_BACK_FADE_RATE = 1500
const KNOCK_BACK_VEL_Y= 0

# Movement.
const SPEED_X = 200
const GRAVITY = 600
const RANDOM_MOVEMENT_MIN_STEPS = 3
const RANDOM_MOVEMENT_MAX_STEPS = 6
const RANDOM_MOVEMENT_MIN_TIME_PER_STEP = 1.0
const RANDOM_MOVEMENT_MAX_TIME_PER_STEP = 2.0

# Animation.
const DIE_ANIMATION_DURATION = 0.8
const STONED_DIE_ANIMATION_DURATION = 0.5
const TOSS_ANIM_DURATION = 2.0
const STONED_ANIM_DURATION = 1.0

var health_changed = false
var attack_target = null
var status_timer = null
var die_timer = null
var knockable = true
var facing = -1

onready var platform_layer = ProjectSettings.get_setting("layer_names/2d_physics/hero_only_platform")

onready var droppuffs = [
	$"Animation/DropPuffLeft",
	$"Animation/DropPuffRight"
]

# Ring spawning.
var ring = preload("res://Scenes/Enemies/Computer Room/Harddies Ring.tscn")
onready var ring_spawn_pos = $"Animation/Ring Spawn Pos"
onready var spawn_node = $".."

onready var impassible_platform = $Platform

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)

# Audio.
onready var shoot_audio = $Audio/Shoot
onready var drop_audio = $Audio/Drop

func activate():
	ec.init_gravity_movement(GRAVITY)
	ec.init_straight_line_movement(facing * SPEED_X, 0)
	set_process(true)
	ec.change_status(FLY)
	$"Animation/Damage Area".add_to_group("enemy")

func _process(delta):
	if ec.not_hurt_dying_stunned():
		match ec.status:
			FLY:
				apply_random_movement(delta)
			TOSS_ANIM:
				play_toss_animation()
			TOSS:
				toss_ring()
			FALLING:
				fall_and_detect_landing(delta)
			LANDED:
				landed()

	if knockable:
		ec.perform_knock_back_movement(delta)

	global_position.x = clamp(global_position.x, left_limit, right_limit)

func change_status(to_status):
	ec.change_status(to_status)

func apply_random_movement(delta):
	ec.play_animation("Fly")
	if ec.random_movement == null:
		ec.init_random_movement("movement_not_ended", "movement_ended", SPEED_X, 0, true, RANDOM_MOVEMENT_MIN_STEPS, RANDOM_MOVEMENT_MAX_STEPS, RANDOM_MOVEMENT_MIN_TIME_PER_STEP, RANDOM_MOVEMENT_MAX_TIME_PER_STEP)

	ec.perform_random_movement(delta)

func movement_not_ended(movement_dir):
	return

func movement_ended():
	detect_and_face_the_farthest_target()
	ec.change_status(TOSS_ANIM)

func detect_and_face_the_farthest_target():
	attack_target = ec.target_detect.get_farthest(self, ec.hero_manager.heroes)
	facing = -1 if attack_target.global_position.x < global_position.x else 1
	ec.turn_sprites_x(facing)

func play_toss_animation():
	ec.play_animation("Toss Ring")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(TOSS_ANIM_DURATION, self, "change_status", TOSS)

func toss_ring():
	ec.change_status(NONE)
	spawn_two_rings()
	shoot_audio.play()
	status_timer = ec.cd_timer.new(STONED_ANIM_DURATION, self, "change_status", FALLING)

func spawn_two_rings():
	var start_pos = global_position
	var end_pos = attack_target.global_position

	var left_ring = ring.instance()
	left_ring.initialize(start_pos, Vector2(end_pos.x - RING_SPAWN_OFFSET, end_pos.y))

	var right_ring = ring.instance()
	right_ring.initialize(start_pos, Vector2(end_pos.x + RING_SPAWN_OFFSET, end_pos.y))

	spawn_node.add_child(left_ring)
	spawn_node.add_child(right_ring)

	left_ring.global_position = ring_spawn_pos.global_position
	right_ring.global_position = ring_spawn_pos.global_position

func fall_and_detect_landing(delta):
	ec.play_animation("Stiff")

	if !health_changed:
		var percentage = float(ec.health_system.health) / float(ec.health_system.full_health)
		ec.health_system.full_health = int(STONED_MAX_HEALTH * (ec.HEALTH_MULTIPLIER_FOR_COOP if get_node("/root/PlayerSettings").heroes_chosen.size() > 1 else 1))
		ec.health_system.health = int(ec.health_system.full_health * percentage)

	ec.perform_gravity_movement(delta)

	if ec.gravity_movement.is_landed:
		for puff in droppuffs:
			puff.emitting = true
		drop_audio.play()
		change_status(LANDED)

func on_attack_hit(area):
	if ec.status == FALLING && area.is_in_group("hero"):
		var character = area.get_node("..")
		character.damaged(DAMAGE, false)
		
		var dir = -1 if character.global_position.x < global_position.x else 1
		character.knocked_back(dir * KNOCK_BACK_VEL_X, KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)

func landed():
	knockable = false
	ec.play_animation("Stiff")
	impassible_platform.set_collision_layer_bit(platform_layer, true)

func damaged(val):
	var play_anim = ec.animator.current_animation != "Toss Ring" && ec.status != FALLING && ec.status != LANDED
	ec.damaged(val, play_anim)

func resume_from_damaged():
	ec.resume_from_damaged()

func healed(val):
	ec.healed(val)

func stunned(duration):
	if ec.status != FALLING && ec.status != LANDED:
		ec.change_status(FLY)
		ec.stunned(duration)

func resume_from_stunned():
	ec.resume_from_stunned()

func knocked_back(vel_x, vel_y, fade_rate):
	if ec.status != FALLING && ec.status != LANDED:
		ec.knocked_back(vel_x, 0, fade_rate)

func slowed(multiplier, duration):
	if ec.status != FALLING && ec.status != LANDED:
		ec.slowed(multiplier, duration)

func slowed_recover(label):
	ec.slowed_recover(label)

func die():
	$"Animation/Damage Area".remove_from_group("enemy")
	
	var animation_key
	var animation_duration

	if ec.status == FALLING || ec.status == LANDED:
		animation_key = "Stiff Die"
		animation_duration = STONED_DIE_ANIMATION_DURATION
	else:
		animation_key = "Die"
		animation_duration = DIE_ANIMATION_DURATION

	change_status(NONE)
	ec.play_animation_and_disble_others(animation_key)
	emit_signal("defeated")
	die_timer = ec.cd_timer.new(animation_duration, self, "queue_free")