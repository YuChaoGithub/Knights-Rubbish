extends KinematicBody2D

# Radiogugu AI:
# 1. Walk randomly. If HP > 50%, go to 2. If HP < 50%, (30% go to 6. 30% go to 2. 40% go to 7).
# 2. Throws casio bombs to slow down a character.
# 3. Walk back until the casio bomb is freed.
# 4. Walk to the character hit by the casio bomb. If none, walk to the farthest.
# 5. Scratch (Attack one chacter in left, one in right if they are in range).
# 6. Drop Floopies. Go to 1.
# 7. Activate laser eyes. (Can be blocked by platforms)
# ===
# Play Hurt animation only when walking. Cannot be stunned.
# Drops 2 stereo bombs when dead.

enum { NONE, RANDOM_ROAM, SLOW_BOMB_ANIM, THROW_SLOW_BOMB, WAIT_SLOW_BOMB_FREED,
	   WALK_TO_CHARACTER, SCRATCH_ANIM, SCRATCH, DROP_FLOOPY_ANIM, DROP_FLOOPY,
	   LASER_EYES_ANIM, LASER_EYES_SHOOT, LASER_EYES_RECOVER }

const MAX_HEALTH = 1200
const ACTIVATE_RANGE = 1000

# Attack.
const SINGLE_SCRATCH_DAMAGE = 15
const SCRATCH_RANGE = 750
const SCRATCH_INTERVAL = 0.3
const SCRATCH_PERFORM_RANGE = 500
const LASER_COUNT = 5
const LASER_SHOW_DURATION = 0.16
const LASER_HIDE_DURATION = 0.04
const LASER_DAMAGE = 7
const KNOCK_BACK_VEL_X = 150
const KNOCK_BACK_VEL_Y = 100
const KNOCK_BACK_FADE_RATE = 300

# Movement.
const SPEED_X = 200
const RUSH_SPEED_X = 400
const GRAVITY = 600
const RANDOM_MOVEMENT_MIN_STEPS = 2
const RANDOM_MOVEMENT_MAX_STEPS = 4
const RANDOM_MOVEMENT_MIN_TIME_PER_STEP = 1.5
const RANDOM_MOVEMENT_MAX_TIME_PER_STEP = 2.5

# Animation.
const DIE_ANIMATION_DURATION = 0.8
const DROP_FLOOPY_FIRST_DURATION = 1.1
const DROP_FLOOPY_SECOND_DURATION = 0.9
const LASER_ACTIVE_ANIMATION_DURATION = 2.5
const LASER_RECOVER_ANIMATION_DURATION = 1.0
const SCRATCH_FIRST_DURATION = 1.0
const SCRATCH_SECOND_DURATION = 1.5
const THROW_WATCH_FIRST_DURATION = 1.4
const THROW_WATCH_SECOND_DURATION = 0.6

const LASER_COLOR = Color(1, 0, 0)
const LASER_THICKNESS = 10

const PLATFORM_LAYER = 2

var status_timer = null
var laser_timer = null
var curr_rand_movement = null
var facing = -1
var attack_target = null
var walk_back_dir = null
var laser_target_left = null
var laser_target_right = null

onready var spawn_node = get_node("..")

# Drop Floopy.
var floopy_spawner = preload("res://Scenes/Enemies/Computer Room/Radiogugu Floopy Spawner.tscn")
onready var floopy_spawn_pos = get_node("Animation/Body/Floopy Spawn Pos")

# Scratch.
var scratch_anim = preload("res://Scenes/Enemies/Computer Room/Radiogugu Claw Skill.tscn")

# Watch Attack.
var watch = preload("res://Scenes/Enemies/Computer Room/Radiogugu Watch Skill.tscn")
var curr_watch = null
onready var watch_spawn_pos = get_node("Animation/Body/Watch Spawn Pos")

# Laser Eyes.
onready var left_laser_spawn_pos = get_node("Animation/Body/Left Laser Spawn Pos")
onready var right_laser_spawn_pos = get_node("Animation/Body/Right Laser Spawn Pos")
onready var drawing_node = get_node("Drawing Node")
onready var raycast_space = get_world_2d().get_direct_space_state()

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)
onready var gravity_movement = ec.gravity_movement.new(self, GRAVITY)
onready var display_screen = get_node("Animation/Body/Head/Display")

func activate():
	set_process(true)
	get_node("Animation/Damage Area").add_to_group("enemy_collider")
	turn_sprites_x(facing)
	ec.change_status(RANDOM_ROAM)

func _process(delta):
	if ec.not_hurt_dying_stunned():
		if ec.status == RANDOM_ROAM:
			random_roam(delta)
		elif ec.status == SLOW_BOMB_ANIM:
			play_slow_bomb_anim()
		elif ec.status == THROW_SLOW_BOMB:
			throw_slow_bomb()
		elif ec.status == WAIT_SLOW_BOMB_FREED:
			walk_back_until_slow_bomb_freed(delta)
		elif ec.status == WALK_TO_CHARACTER:
			walk_to_attack_target(delta)
		elif ec.status == SCRATCH_ANIM:
			play_scratch_anim()
		elif ec.status == SCRATCH:
			scratch()
		elif ec.status == DROP_FLOOPY_ANIM:
			play_drop_floopy_anim()
		elif ec.status == DROP_FLOOPY:
			drop_floopy()
		elif ec.status == LASER_EYES_ANIM:
			play_laser_eyes_anim()
		elif ec.status == LASER_EYES_SHOOT:
			shoot_laser_eyes()
		elif ec.status == LASER_EYES_RECOVER:
			recover_laser_eyes()
	apply_gravity(delta)

func change_status(to_status):
	ec.change_status(to_status)

func turn_sprites_x(facing):
	ec.turn_sprites_x(facing)
	var display_scale = display_screen.get_scale()
	display_screen.set_scale(Vector2(abs(display_scale.x) * facing, display_scale.y))

func apply_gravity(delta):
	move_to(gravity_movement.movement(get_global_pos(), delta))

func random_roam(delta):
	ec.play_animation("Walk")
	if curr_rand_movement == null:
		# New random movement.
		curr_rand_movement = ec.random_movement.new(SPEED_X, 0, true, RANDOM_MOVEMENT_MIN_STEPS, RANDOM_MOVEMENT_MAX_STEPS, RANDOM_MOVEMENT_MIN_TIME_PER_STEP, RANDOM_MOVEMENT_MAX_TIME_PER_STEP)

	if !curr_rand_movement.movement_ended():
		var final_pos = curr_rand_movement.movement(get_global_pos(), delta)

		facing = sign(final_pos.x - get_global_pos().x)
		turn_sprites_x(facing)

		move_to(final_pos)
	else:
		curr_rand_movement = null
		
		# Transition to other status.
		var to_status = NONE
		if get_health_percentage() > 0.5:
			to_status = SLOW_BOMB_ANIM
		else:
			var rand_num = ec.rng.randi_range(0, 100)
			if rand_num < 30:
				to_status = DROP_FLOOPY_ANIM
			elif rand_num < 60:
				to_status = SLOW_BOMB_ANIM
			else:
				to_status = LASER_EYES_ANIM

		ec.change_status(to_status)

func get_health_percentage():
	return float(ec.health_system.health) / float(MAX_HEALTH)

func play_slow_bomb_anim():
	ec.play_animation("Watch Out")
	ec.change_status(NONE)

	# Get farthest character.
	attack_target = ec.target_detect.get_farthest(self, ec.char_average_pos.characters)

	# Face the target
	facing = sign(attack_target.get_global_pos().x - get_global_pos().x)
	turn_sprites_x(facing)

	status_timer = ec.cd_timer.new(THROW_WATCH_FIRST_DURATION, self, "change_status", THROW_SLOW_BOMB)

func throw_slow_bomb():
	ec.change_status(NONE)

	var direction = (attack_target.get_global_pos() - watch_spawn_pos.get_global_pos()).normalized()

	# For walking back.
	walk_back_dir = -facing
	attack_target = null   # The watch will define the attack target.

	# Spawn watch.
	curr_watch = watch.instance()
	curr_watch.initialize(direction, self)
	spawn_node.add_child(curr_watch)
	curr_watch.set_global_pos(watch_spawn_pos.get_global_pos())

	status_timer = ec.cd_timer.new(THROW_WATCH_SECOND_DURATION, self, "change_status", WAIT_SLOW_BOMB_FREED)

func walk_back_until_slow_bomb_freed(delta):
	ec.play_animation("Walk")
	
	facing = walk_back_dir
	turn_sprites_x(facing)

	move(Vector2(SPEED_X * facing * delta, 0))

	if curr_watch == null:
		ec.change_status(WALK_TO_CHARACTER)

func walk_to_attack_target(delta):
	ec.play_animation("Walk")
	
	# Watch didn't hit.
	if attack_target == null:
		attack_target = ec.target_detect.get_farthest(self, ec.char_average_pos.characters)
	
	facing = sign(attack_target.get_global_pos().x - get_global_pos().x)
	turn_sprites_x(facing)
	
	move(Vector2(RUSH_SPEED_X * facing * delta, 0))

	if abs(attack_target.get_global_pos().x - get_global_pos().x) <= SCRATCH_PERFORM_RANGE:
		ec.change_status(SCRATCH_ANIM)

func play_scratch_anim():
	ec.play_animation("Scratch")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(SCRATCH_FIRST_DURATION, self, "change_status", SCRATCH)

func scratch():
	ec.change_status(NONE)
	
	var left_target = null
	var left_distance = -100000
	var right_target = null
	var right_distance = 100000

	for target in ec.char_average_pos.characters:
		var distance = target.get_global_pos().x - get_global_pos().x

		if left_target == null && distance < 0 && distance > -SCRATCH_RANGE && distance > left_distance:
			left_target = target
			left_distance = distance

		if right_target == null && distance > 0 && distance < SCRATCH_RANGE && distance < right_distance:
			right_target = target
			right_distance = distance

	if left_target != null:
		apply_scratch_damage(left_target, -1)

		var left_scratch = scratch_anim.instance()
		left_target.add_child(left_scratch)
	
	if right_target != null:
		apply_scratch_damage(right_target, 1)

		var right_scratch = scratch_anim.instance()
		right_target.add_child(right_scratch)

	status_timer = ec.cd_timer.new(SCRATCH_SECOND_DURATION, self, "change_status", DROP_FLOOPY_ANIM)

func apply_scratch_damage(target, knock_back_dir):
	target.damaged_over_time(SCRATCH_INTERVAL, 2, SINGLE_SCRATCH_DAMAGE)
	target.knocked_back(knock_back_dir * KNOCK_BACK_VEL_X, -KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)

func play_drop_floopy_anim():
	ec.play_animation("Drop Floopies")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(DROP_FLOOPY_FIRST_DURATION, self, "change_status", DROP_FLOOPY)

func drop_floopy():
	ec.change_status(NONE)

	var floopy_spawner_instance = floopy_spawner.instance()
	spawn_node.add_child(floopy_spawner_instance)
	floopy_spawner_instance.set_global_pos(floopy_spawn_pos.get_global_pos())

	status_timer = ec.cd_timer.new(DROP_FLOOPY_SECOND_DURATION, self, "change_status", RANDOM_ROAM)

func play_laser_eyes_anim():
	ec.play_animation("Laser")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(LASER_ACTIVE_ANIMATION_DURATION, self, "change_status", LASER_EYES_SHOOT)

func shoot_laser_eyes():
	find_laser_targets()
	laser_sequence_on()
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new((LASER_SHOW_DURATION + LASER_HIDE_DURATION) * LASER_COUNT, self, "change_status", LASER_EYES_RECOVER)

func find_laser_targets():
	laser_target_left = ec.target_detect.get_nearest(left_laser_spawn_pos, ec.char_average_pos.characters)
	laser_target_right = ec.target_detect.get_nearest(right_laser_spawn_pos, ec.char_average_pos.characters)

func laser_sequence_on():
	var left_laser_from = left_laser_spawn_pos.get_global_pos()
	var right_laser_from = right_laser_spawn_pos.get_global_pos()

	var left_laser_to = laser_target_left.get_global_pos()
	var right_laser_to = laser_target_right.get_global_pos()

	var left_ray_hit = raycast_space.intersect_ray(left_laser_from, left_laser_to, [self], PLATFORM_LAYER)
	var right_ray_hit = raycast_space.intersect_ray(right_laser_from, right_laser_to, [self], PLATFORM_LAYER)

	var laser_line_left = {
		from_pos = left_laser_from - get_global_pos(),
		to_pos = (left_ray_hit.position if left_ray_hit.size() != 0 else left_laser_to) - get_global_pos(),
		color = LASER_COLOR,
		width = LASER_THICKNESS
	}
	
	var laser_line_right = {
		from_pos = right_laser_from - get_global_pos(),
		to_pos = (right_ray_hit.position if right_ray_hit.size() != 0 else right_laser_to) - get_global_pos(),
		color = LASER_COLOR,
		width = LASER_THICKNESS
	}
	
	drawing_node.add_line(laser_line_left)
	drawing_node.add_line(laser_line_right)

	if left_ray_hit.size() == 0:
		laser_target_left.damaged(LASER_DAMAGE)

	if right_ray_hit.size() == 0:
		laser_target_right.damaged(LASER_DAMAGE)

	laser_timer = ec.cd_timer.new(LASER_SHOW_DURATION, self, "laser_sequence_off")

func laser_sequence_off():
	drawing_node.clear_all()
	laser_timer = ec.cd_timer.new(LASER_HIDE_DURATION, self, "laser_sequence_on")

func recover_laser_eyes():
	cancel_laser_sequence()
	ec.play_animation("Laser Recover")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(LASER_RECOVER_ANIMATION_DURATION, self, "change_status", RANDOM_ROAM)

func cancel_laser_sequence():
	drawing_node.clear_all()
	if laser_timer != null:
		laser_timer.destroy_timer()
		laser_timer = null

func damaged(val):
	var play_hurt_anim = ec.animator.get_current_animation() == "Walk"
	ec.damaged(val, play_hurt_anim)

func resume_from_damaged():
	ec.resume_from_damaged()

func stunned(duration):
	ec.display_immune_text()

func damaged_over_time(time_per_tick, total_ticks, damage_per_tick):
	ec.damaged_over_time(time_per_tick, total_ticks, damage_per_tick)

func healed(val):
	ec.healed(val)

func healed_over_time(time_per_tick, total_ticks, heal_per_tick):
	ec.healed_over_time(time_per_tick, total_ticks, heal_per_tick)

func die():
	ec.die()
	cancel_laser_sequence()
	status_timer = ec.cd_timer.new(DIE_ANIMATION_DURATION, self, "queue_free")