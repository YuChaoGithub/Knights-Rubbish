extends Node2D

# Chromoghast AI:
# 1. Move randomly.
# 2. Turn invisible (can't be harmed), move randomly.
# 3. Move randomly.
# 4. Face the nearest character. Throws shuriken.
# 5. Repeat 1.

enum { NONE, FIRST_MOVE, TURN_INVISIBLE, INVISIBLE_MOVE, TURN_OPAQUE, SECOND_MOVE, THROW_ANIM, THROW }

const MAX_HEALTH = 300

const ACTIVATE_RANGE = 1500

# Movement.
const SPEED_X = 250
const RANDOM_MOVEMENT_MIN_STEPS = 1
const RANDOM_MOVEMENT_MAX_STEPS = 3
const RANDOM_MOVEMENT_MIN_TIME_PER_STEP = 0.6
const RANDOM_MOVEMENT_MAX_TIME_PER_STEP = 1.0

# Animation.
const TURN_INVISIBLE_DURATION = 0.5
const TURN_OPAQUE_DURATION = 0.5
const THROW_ANIMATION_DURATION = 1.1
const THROWING_DURATION = 0.4
const DIE_ANIMATION_DURATION = 0.5

var status_timer = null
var curr_rand_movement = null
var facing = -1

# Shuriken.
var shuriken = preload("res://Scenes/Enemies/Computer Room/Chromoghast Shuriken.tscn")
onready var shuriken_spawn_pos = get_node("Animation/Shuriken Spawn Pos")
onready var spawn_node = get_node("..")

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)

func activate():
	set_process(true)
	ec.change_status(FIRST_MOVE)
	get_node("Animation/Damage Area").add_to_group("enemy_collider")

func _process(delta):
	if ec.not_hurt_dying_stunned():
		if ec.status == FIRST_MOVE:
			perform_first_move(delta)
		elif ec.status == TURN_INVISIBLE:
			turn_invisible()
		elif ec.status == INVISIBLE_MOVE:
			perform_invisible_move(delta)
		elif ec.status == TURN_OPAQUE:
			turn_opaque()
		elif ec.status == SECOND_MOVE:
			perform_second_move(delta)
		elif ec.status == THROW_ANIM:
			play_throw_anim()
		elif ec.status == THROW:
			throw_shuriken()

func change_status(to_status):
	ec.change_status(to_status)

func perform_random_movement(delta, ending_func):
	if curr_rand_movement == null:
		curr_rand_movement = ec.random_movement.new(SPEED_X, 0, true, RANDOM_MOVEMENT_MIN_STEPS, RANDOM_MOVEMENT_MAX_STEPS, RANDOM_MOVEMENT_MIN_TIME_PER_STEP, RANDOM_MOVEMENT_MAX_TIME_PER_STEP)

	if curr_rand_movement.movement_ended():
		curr_rand_movement = null
		self.call(ending_func)
	else:
		var final_pos = curr_rand_movement.movement(get_global_pos(), delta)

		if final_pos.x < get_global_pos().x:
			facing = -1
		elif final_pos.x > get_global_pos().x:
			facing = 1
		ec.turn_sprites_x(facing)

		set_global_pos(final_pos)

func perform_first_move(delta):
	ec.play_animation("Walk")
	perform_random_movement(delta, "first_move_ended")

func first_move_ended():
	ec.change_status(TURN_INVISIBLE)

func turn_invisible():
	ec.play_animation("Turn Invisible")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(TURN_INVISIBLE_DURATION, self, "change_status", INVISIBLE_MOVE)

func perform_invisible_move(delta):
	perform_random_movement(delta, "invisible_move_ended")

func invisible_move_ended():
	ec.change_status(TURN_OPAQUE)

func turn_opaque():
	ec.play_animation("Turn Opaque")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(TURN_OPAQUE_DURATION, self, "change_status", SECOND_MOVE)

func perform_second_move(delta):
	ec.play_animation("Walk")
	perform_random_movement(delta, "second_move_ended")

func second_move_ended():
	# Face the nearest target.
	var target = ec.target_detect.get_nearest(self, ec.char_average_pos.characters)
	facing = sign(target.get_global_pos().x - get_global_pos().x)
	ec.turn_sprites_x(facing)

	ec.change_status(THROW_ANIM)

func play_throw_anim():
	ec.play_animation("Throw Shuriken")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(THROW_ANIMATION_DURATION, self, "change_status", THROW)

func throw_shuriken():
	ec.change_status(NONE)

	var new_shuriken = shuriken.instance()
	
	new_shuriken.initialize(facing)
	spawn_node.add_child(new_shuriken)
	new_shuriken.set_global_pos(shuriken_spawn_pos.get_global_pos())

	status_timer = ec.cd_timer.new(THROWING_DURATION, self, "change_status", FIRST_MOVE)

func damaged(val):
	ec.damaged(val, ec.animator.get_current_animation() == "Walk")

func resume_from_damaged():
	ec.resume_from_damaged()

func stunned(duration):
	ec.change_status(FIRST_MOVE)
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