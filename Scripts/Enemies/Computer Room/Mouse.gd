extends KinematicBody2D

# Mouse AI:
# 1. Move randomly for a random interval.
# 2. Turn to the side which the nearest character is facing.
# 3. Open lid.
# 4. Spawn small mousy bullet.
# 5. Close lid.
# 6. Repeat 1.
# ===
# Being hurt or stunned: go to 1.

enum { NONE, MOVE, OPEN, FIRE, CLOSE }

const MAX_HEALTH = 350

const ACTIVATE_RANGE = 1600

# Movement.
const SPEED_X = 200
const GRAVITY = 600
const RANDOM_MOVEMENT_MIN_STEPS = 3
const RANDOM_MOVEMENT_MAX_STEPS = 6
const RANDOM_MOVEMENT_MIN_TIME_PER_STEP = 0.4
const RANDOM_MOVEMENT_MAX_TIME_PER_STEP = 0.7

# Animation.
const OPEN_ANIMATION_DURATION = 1.0
const CLOSE_ANIMATION_DURATION = 1.0
const SPAWN_MOUSY_DURATION = 0.25
const DIE_ANIMATION_DURATION = 0.5

var status_timer = null
var curr_rand_movement = null
var facing = -1

var mousy_bomb = preload("res://Scenes/Enemies/Computer Room/Mousy Bomb.tscn")
onready var mousy_spawn_pos = get_node("Animation/Mousy Spawn Pos")
onready var mousy_parent_node = get_node("..")

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)
onready var gravity_movement = ec.gravity_movement.new(self, GRAVITY)

func activate():
	set_process(true)

	ec.change_status(MOVE)

	# Become damagable.
	get_node("Animation/Damage Area").add_to_group("enemy_collider")

func _process(delta):
	if ec.not_hurt_dying_stunned():
		if ec.status == MOVE:
			perform_movement(delta)
		elif ec.status == OPEN:
			open_lid()
		elif ec.status == FIRE:
			spawn_mousy()
		elif ec.status == CLOSE:
			close_lid()

	apply_gravity(delta)

func change_status(to_status):
	ec.change_status(to_status)

func apply_gravity(delta):
	move_to(gravity_movement.movement(get_global_pos(), delta))

func perform_movement(delta):
	ec.play_animation("Walk")
	if curr_rand_movement == null:
		# New random movement.
		curr_rand_movement = ec.random_movement.new(SPEED_X, 0, true, RANDOM_MOVEMENT_MIN_STEPS, RANDOM_MOVEMENT_MAX_STEPS, RANDOM_MOVEMENT_MIN_TIME_PER_STEP, RANDOM_MOVEMENT_MAX_TIME_PER_STEP)

	if !curr_rand_movement.movement_ended():
		# Perform random movement sequence.
		var final_pos = curr_rand_movement.movement(get_global_pos(), delta)
		
		# Turn sprite if it is moving in a different direction.
		if final_pos.x < get_global_pos().x:
			facing = -1
		elif final_pos.x > get_global_pos().x:
			facing = 1
		ec.turn_sprites_x(facing)

		move_to(final_pos)
	else:
		face_the_nearest_target()
		curr_rand_movement = null
		ec.change_status(OPEN)

func open_lid():
	ec.play_animation("Open Lid")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(OPEN_ANIMATION_DURATION, self, "change_status", FIRE)

func spawn_mousy():
	var new_mousy = mousy_bomb.instance()
	new_mousy.facing = facing
	new_mousy.set_global_pos(mousy_spawn_pos.get_global_pos())
	mousy_parent_node.add_child(new_mousy)

	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(SPAWN_MOUSY_DURATION, self, "change_status", CLOSE)

func face_the_nearest_target():
	var target = ec.target_detect.get_nearest(self, ec.char_average_pos.characters)
	facing = -1 if target.get_global_pos().x < get_global_pos().x else 1
	ec.turn_sprites_x(facing)

func close_lid():
	ec.play_animation("Close Lid")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(CLOSE_ANIMATION_DURATION, self, "change_status", MOVE)

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