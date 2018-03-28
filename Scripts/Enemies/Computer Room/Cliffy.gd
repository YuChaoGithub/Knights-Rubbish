extends Node2D

# Cliffy AI:
# 1. Move to a random location. 50% go to 2, 50% go to 3.
# 2. Talk bubble -> throw light bulb bomb. Go to 1.
# 3. Exclaimation mark -> shoot little clips. Go to 1.
# ===
# Play hurt animation only when moving.
# Go to 1 when stunned.

enum { NONE, MOVE, BUBBLE_ANIM, SHOOT_BUBBLE, DART_ANIM, SHOOT_DART }

export(int) var activate_range_x = 1500
export(int) var activate_range_y = 1500

const MAX_HEALTH = 125

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
var facing = -1

onready var spawn_node = $".."

# Bubble.
var bubble = preload("res://Scenes/Enemies/Computer Room/Cliffy Light Bulb.tscn")
onready var bubble_spawn_pos = $"Animation/Bubble Spawn Pos"

# Dart.
var dart = preload("res://Scenes/Enemies/Computer Room/Cliffy Clip Shuriken.tscn")
onready var dart_spawn_poses = [
	$"Animation/Dart Spawn Pos 1",
	$"Animation/Dart Spawn Pos 2",
	$"Animation/Dart Spawn Pos 3"
]
var darts = []

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)

func activate():
	set_process(true)
	ec.change_status(MOVE)
	$"Animation/Damage Area".add_to_group("enemy")

func _process(delta):
	if ec.not_hurt_dying_stunned():
		match ec.status:
			MOVE:
				apply_movement(delta)
			BUBBLE_ANIM:
				play_bubble_anim()
			SHOOT_BUBBLE:
				shoot_bubble()
			DART_ANIM:
				play_dart_anim()
			SHOOT_DART:
				shoot_dart()

	ec.perform_knock_back_movement(delta)
		
func change_status(to_status):
	ec.change_status(to_status)

func apply_movement(delta):
	ec.play_animation("Walk")

	if ec.random_movement == null:
		ec.init_random_movement("movement_not_ended", "movement_ended", SPEED_X, 0, true, RANDOM_MOVEMENT_MIN_STEPS, RANDOM_MOVEMENT_MAX_STEPS, RANDOM_MOVEMENT_MIN_TIME_PER_STEP, RANDOM_MOVEMENT_MAX_TIME_PER_STEP)

	ec.perform_random_movement(delta)
		

func movement_not_ended(movement_dir):
	facing = movement_dir
	ec.turn_sprites_x(facing)

func movement_ended():
	face_nearest_target()
	var to_status = BUBBLE_ANIM if ec.rng.randsign() == 1 else DART_ANIM
	ec.change_status(to_status)

func face_nearest_target():
	var target = ec.target_detect.get_nearest(self, ec.hero_average_pos.characters)
	facing = sign(target.global_position.x - global_position.x)
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
	new_bubble.global_position = bubble_spawn_pos.global_position

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
	new_dart.global_position = dart_spawn_poses[count].global_position
	
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
	ec.damaged(val, ec.animator.current_animation == "Walk")

func resume_from_damaged():
	ec.resume_from_damaged()

func stunned(duration):
	cancel_dart_spawn_and_dart_instaces()
	ec.change_status(MOVE)
	ec.stunned(duration)

func resume_from_stunned():
	ec.resume_from_stunned()

func healed(val):
	ec.healed(val)

func knocked_back(vel_x, vel_y, fade_rate):
	var curr_anim = ec.animator.current_animation
	if curr_anim != "Exclaim" && curr_anim != "Light bulb":
		ec.knocked_back(vel_x, 0, fade_rate)

func slowed(multiplier, duration):
	ec.slowed(multiplier, duration)

func slowed_recover(label):
	ec.slowed_recover(label)

func die():
	cancel_dart_spawn_and_dart_instaces()
	ec.die()
	status_timer = ec.cd_timer.new(DIE_ANIMATION_DURATION, self, "queue_free")