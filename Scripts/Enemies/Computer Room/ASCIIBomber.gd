extends KinematicBody2D

# ASCII Bomber AI:
# 1. Move to a random location.
# 2. Face the nearest character, throws Bomb.
# 3. Repeat 1.

export(int) var activate_range_x = 1500
export(int) var activate_range_y = 10000

enum { NONE, MOVE, THROW_ANIM, THROW }

const MAX_HEALTH = 100

# Movement.
const SPEED_X = 200
const GRAVITY = 600
const RANDOM_MOVEMENT_STEPS = 1
const RANDOM_MOVEMENT_MIN_TIME_PER_STEP = 2.0
const RANDOM_MOVEMENT_MAX_TIME_PER_STEP = 4.0

# Animation.
const DIE_ANIMATION_DURATION = 0.5
const THROW_ANIMATION_DURATION = 1.2
const THROWING_DURATION = 0.3

var status_timer = null
var die_timer = null
var facing = -1

# Throw bomb.
onready var bomb = preload("res://Scenes/Enemies/Computer Room/ASCII Bomber bomb.tscn")
onready var bomb_spawn_pos = $"Animation/Bomb Spawn Pos"
onready var spawn_node = $".."

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)

func activate():
	ec.init_gravity_movement(GRAVITY)
	set_process(true)
	ec.change_status(MOVE)
	$"Animation/Damage Area".add_to_group("enemy")

func _process(delta):
	if ec.not_hurt_dying_stunned():
		match ec.status:
			MOVE:
				apply_movement(delta)
			THROW_ANIM:
				play_throw_anim()
			THROW:
				throw_bomb()	

	ec.perform_gravity_movement(delta)
	ec.perform_knock_back_movement(delta)

func change_status(to_status):
	ec.change_status(to_status)

func apply_movement(delta):
	ec.play_animation("Walk")

	if ec.random_movement == null:
		ec.init_random_movement("movement_not_ended", "movement_ended", SPEED_X, 0, true, RANDOM_MOVEMENT_STEPS, RANDOM_MOVEMENT_STEPS, RANDOM_MOVEMENT_MIN_TIME_PER_STEP, RANDOM_MOVEMENT_MAX_TIME_PER_STEP)

	ec.perform_random_movement(delta)

func movement_not_ended(movement_dir):
	facing = movement_dir
	ec.turn_sprites_x(facing)

func movement_ended():
	ec.change_status(THROW_ANIM)

func play_throw_anim():
	# Face the nearest character.
	var target_pos = ec.target_detect.get_nearest(self, ec.hero_manager.heroes).global_position
	facing = sign(target_pos.x - global_position.x)
	ec.turn_sprites_x(facing)

	ec.play_animation("Throw Bomb")

	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(THROW_ANIMATION_DURATION, self, "change_status", THROW)

func throw_bomb():
	var new_bomb = bomb.instance()
	new_bomb.initialize(facing)
	spawn_node.add_child(new_bomb)
	new_bomb.global_position = bomb_spawn_pos.global_position

	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(THROWING_DURATION, self, "change_status", MOVE)

func damaged(val):
	ec.damaged(val, ec.animator.current_animation == "Walk")

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
	ec.die()
	die_timer = ec.cd_timer.new(DIE_ANIMATION_DURATION, self, "queue_free")