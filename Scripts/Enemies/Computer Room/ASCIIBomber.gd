extends KinematicBody2D

# ASCII Bomber AI:
# 1. Move to a random location.
# 2. Face the nearest character, throws Bomb.
# 3. Repeat 1.

enum { NONE, MOVE, THROW_ANIM, THROW }

const MAX_HEALTH = 100

const ACTIVATE_RANGE = 1500

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
var curr_rand_movement = null
var facing = -1

# Throw bomb.
onready var bomb = preload("res://Scenes/Enemies/Computer Room/ASCII Bomber bomb.tscn")
onready var bomb_spawn_pos = get_node("Animation/Bomb Spawn Pos")
onready var spawn_node = get_node("..")

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)
onready var gravity_movement = ec.gravity_movement.new(self, GRAVITY)

func activate():
	set_process(true)
	ec.change_status(MOVE)
	get_node("Animation/Damage Area").add_to_group("player_collider")

func _process(delta):
	if ec.not_hurt_dying_stunned():
		if ec.status == MOVE:
			apply_movement(delta)
		elif ec.status == THROW_ANIM:
			play_throw_anim()
		elif ec.status == THROW:
			throw_bomb()

	apply_gravity(delta)

func change_status(to_status):
	ec.change_status(to_status)

func apply_gravity(delta):
	move_to(gravity_movement.movement(get_global_pos(), delta))

func apply_movement(delta):
	ec.play_animation("Walk")

	if curr_rand_movement == null:
		curr_rand_movement = ec.random_movement.new(SPEED_X, 0, true, RANDOM_MOVEMENT_STEPS, RANDOM_MOVEMENT_STEPS, RANDOM_MOVEMENT_MIN_TIME_PER_STEP, RANDOM_MOVEMENT_MAX_TIME_PER_STEP)

	if curr_rand_movement.movement_ended():
		curr_rand_movement = null
		ec.change_status(THROW_ANIM)
	else:
		var final_pos = curr_rand_movement.movement(get_global_pos(), delta)

		if final_pos.x < get_global_pos().x:
			facing = -1
		elif final_pos.x > get_global_pos().x:
			facing = 1
		ec.turn_sprites_x(facing)

		move_to(final_pos)

func play_throw_anim():
	# Face the nearest character.
	var target_pos = ec.target_detect.get_nearest(self, ec.char_average_pos.characters).get_global_pos()
	facing = sign(target_pos.x - get_global_pos().x)
	ec.turn_sprites_x(facing)

	ec.play_animation("Throw Bomb")

	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(THROW_ANIMATION_DURATION, self, "change_status", THROW)

func throw_bomb():
	var new_bomb = bomb.instance()
	new_bomb.set_global_pos(bomb_spawn_pos.get_global_pos())
	new_bomb.initialize(facing)
	spawn_node.add_child(new_bomb)

	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(THROWING_DURATION, self, "change_status", MOVE)

func damaged(val):
	ec.damaged(val, ec.animator.get_current_animation() == "Walk")

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