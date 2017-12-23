extends Node2D

# Cliffy AI:
# 1. Move to a random location. 50% go to 2, 50% go to 3.
# 2. Talk bubble -> throw light bulb bomb. Go to 1.
# 3. Exclaimation mark -> shoot little clips. Go to 1.
# ===
# Play hurt animation only when moving.
# Go to 1 when stunned.

enum { NONE, MOVE, BUBBLE_ANIM, SHOOT_BUBBLE, DART_ANIM, SHOOT_DART }

const MAX_HEALTH = 125

const ACTIVATE_RANGE = 1250

# Movement.
const SPEED_X = 250
const RANDOM_MOVEMENT_MIN_STEPS = 1
const RANDOM_MOVEMENT_MAX_STEPS = 2
const RANDOM_MOVEMENT_MIN_TIME_PER_STEP = 2.0
const RANDOM_MOVEMENT_MAX_TIME_PER_STEP = 3.5

# Animation.
const DIE_ANIMATION_DURATION = 0.5
const BUBBLE_ANIMATION_DURATION = 2.8
const SHOOT_BUBBLE_DURATION = 0.2
const SPAWN_DART_INTERVAL = 0.3

var status_timer = null
var dart_spawn_timer = null
var curr_rand_movement = null
var facing = -1

onready var spawn_node = get_node("..")

# Bubble.
var bubble = preload("res://Scenes/Enemies/Computer Room/Cliffy Light Bulb.tscn")
onready var bubble_spawn_pos = get_node("Animation/Bubble Spawn Pos")

# Dart.
var dart = preload("res://Scenes/Enemies/Computer Room/Cliffy Clip Shuriken.tscn")
onready var dart_spawn_poses = [
	get_node("Animation/Dart Spawn Pos 1"),
	get_node("Animation/Dart Spawn Pos 2"),
	get_node("Animation/Dart Spawn Pos 3")
]
var darts = []

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)

func activate():
	set_process(true)
	ec.change_status(MOVE)
	get_node("Animation/Damage Area").add_to_group("enemy_collider")

func _process(delta):
	if ec.not_hurt_dying_stunned():
		if ec.status == MOVE:
			apply_movement(delta)
		elif ec.status == BUBBLE_ANIM:
			play_bubble_anim()
		elif ec.status == SHOOT_BUBBLE:
			shoot_bubble()
		elif ec.status == DART_ANIM:
			play_dart_anim()
		elif ec.status == SHOOT_DART:
			shoot_dart()
		
func change_status(to_status):
	ec.change_status(to_status)

func apply_movement(delta):
	ec.play_animation("Walk")

	if curr_rand_movement == null:
		curr_rand_movement = ec.random_movement.new(SPEED_X, 0, true, RANDOM_MOVEMENT_MIN_STEPS, RANDOM_MOVEMENT_MAX_STEPS, RANDOM_MOVEMENT_MIN_TIME_PER_STEP, RANDOM_MOVEMENT_MAX_TIME_PER_STEP)

	if curr_rand_movement.movement_ended():
		curr_rand_movement = null
		face_nearest_target()
		var to_status = BUBBLE_ANIM if ec.rng.randsign() == 1 else DART_ANIM
		ec.change_status(to_status)
	else:
		var final_pos = curr_rand_movement.movement(get_global_pos(), delta)

		if final_pos.x < get_global_pos().x:
			facing = -1
		elif final_pos.x > get_global_pos().x:
			facing = 1
		ec.turn_sprites_x(facing)

		set_global_pos(final_pos)

func face_nearest_target():
	var target = ec.target_detect.get_nearest(self, ec.char_average_pos.characters)
	facing = sign(target.get_global_pos().x - get_global_pos().x)
	ec.turn_sprites_x(facing)

func play_bubble_anim():
	ec.play_animation("Light bulb")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(BUBBLE_ANIMATION_DURATION, self, "change_status", SHOOT_BUBBLE)

func shoot_bubble():
	ec.change_status(NONE)

	var new_bubble = bubble.instance()
	new_bubble.initialize(facing)
	spawn_node.add_child(new_bubble)
	new_bubble.set_global_pos(bubble_spawn_pos.get_global_pos())

	status_timer = ec.cd_timer.new(SHOOT_BUBBLE_DURATION, self, "change_status", MOVE)

func play_dart_anim():
	ec.play_animation("Exclaim")
	ec.change_status(NONE)
	spawn_dart(0)

func spawn_dart(count):
	if count >= dart_spawn_poses.size():
		status_timer = ec.cd_timer.new(SPAWN_DART_INTERVAL, self, "change_status", SHOOT_DART)
		dart_spawn_timer = null
		return

	var new_dart = dart.instance()
	new_dart.initialize(facing)
	darts.push_back(new_dart)
	spawn_node.add_child(new_dart)
	new_dart.set_global_pos(dart_spawn_poses[count].get_global_pos())
	
	dart_spawn_timer = ec.cd_timer.new(SPAWN_DART_INTERVAL, self, "spawn_dart", count + 1)

func shoot_dart():
	ec.change_status(NONE)
		
	for dart_instance in darts:
		dart_instance.start_travel()

	darts.clear()

	status_timer = ec.cd_timer.new(SPAWN_DART_INTERVAL, self, "change_status", MOVE)

func cancel_dart_spawn_and_dart_instaces():
	if dart_spawn_timer != null:
		dart_spawn_timer.destroy_timer()
		dart_spawn_timer = null
	
	for dart_instance in darts:
		dart_instance.queue_free()

	darts.clear()

func damaged(val):
	ec.damaged(val, ec.animator.get_current_animation() == "Walk")

func resume_from_damaged():
	ec.resume_from_damaged()

func stunned(duration):
	cancel_dart_spawn_and_dart_instaces()
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
	cancel_dart_spawn_and_dart_instaces()
	ec.die()
	status_timer = ec.cd_timer.new(DIE_ANIMATION_DURATION, self, "queue_free")