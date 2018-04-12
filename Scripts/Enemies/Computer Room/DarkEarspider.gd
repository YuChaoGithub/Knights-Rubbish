extends Node2D

# Dark Earspider AI:
# 1. Move horizontally to the place above a character (in bounds but farthest).
# 2. Drop down on the character's head.
# 3. Clap! (Stunning the character)
# 4. Move back up.
# 5. Do some random movement.
# 6. Repeat 1.
# ===
# If damaged or stunned, perform 4.

enum { NONE, MOVE, DROP, CLAP, CLIMB, RANDOM_MOVEMENT }

export(int) var activate_range_x = 1500
export(int) var activate_range_y = 1500

const MAX_HEALTH = 200

# Movement.
const SPEED_X = 200
const SPEED_Y = 1000
const RANDOM_MOVEMENT_MIN_STEPS = 2
const RANDOM_MOVEMENT_MAX_STEPS = 4
const RANDOM_MOVEMENT_MIN_TIME_PER_STEP = 0.25
const RANDOM_MOVEMENT_MAX_TIME_PER_STEP = 0.6

const DROPPING_TO_CHAR_OFFSET_X = 200
const DROPPING_TO_CHAR_OFFSET_Y = 125

const CLAP_STUN_DURATION = 1.5

const ATTACHED_SILK_THICKNESS = 5

# Animation.
const CLAP_ANIMATION_DURATION = 0.7
const DIE_ANIMATION_DURATION = 0.5

# It can only move between the bounds.
export(int) var left_bound
export(int) var right_bound

var attack_target = null
var status_timer = null
var curr_rand_movement = null

onready var original_pos = position
onready var silk_attach_spot = $"Animation/Body/Silk Pos"
onready var silk_attach_spot_original_pos = silk_attach_spot.global_position

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)
onready var movement_type = preload("res://Scripts/Movements/StraightLineMovement.gd").new(0, 0)

func activate():
	set_process(true)

	search_for_target()

	# Become damagable.
	$"Animation/Damage Area".add_to_group("enemy")
	
	ec.change_status(MOVE)

func _process(delta):
	update()

	if ec.not_hurt_dying_stunned():
		match ec.status:
			MOVE:
				move_horizontally_to_target(delta)
			DROP:
				drop_down(delta)
			CLAP:
				clap_attack()
			CLIMB:
				climb_up(delta)
			RANDOM_MOVEMENT:
				perform_random_movement(delta)

func _draw():
	# Draw the attached black silk.
	var from_pos = silk_attach_spot.global_position - global_position
	var to_pos = Vector2(from_pos.x, from_pos.y - (silk_attach_spot.global_position.y - silk_attach_spot_original_pos.y))
	draw_line(from_pos, to_pos, Color(0, 0, 0), ATTACHED_SILK_THICKNESS)

func change_status(to_status):
	ec.change_status(to_status)

func search_for_target():
	# Find the farthest character as its attacking target.
	attack_target = ec.target_detect.get_farthest(self, ec.hero_manager.heroes)

func move_horizontally_to_target(delta):
	ec.play_animation("Swing")
	var difference_x = attack_target.global_position.x - global_position.x

	# Apply horizontal movement.
	movement_type.set_velocity(sign(difference_x) * SPEED_X, 0)
	var final_pos = position + movement_type.movement(delta)
	final_pos.x = clamp(final_pos.x, original_pos.x - left_bound, original_pos.x + left_bound)
	position = final_pos

	# Close enough, land after a delay.
	if abs(difference_x) <= DROPPING_TO_CHAR_OFFSET_X:
		ec.change_status(DROP)

func drop_down(delta):
	ec.play_animation("Drop")
	movement_type.set_velocity(0, SPEED_Y)
	position += movement_type.movement(delta)

	# Close enough or the target is above, perform clap attack.
	var target_y = attack_target.global_position.y
	var curr_y = global_position.y
	if curr_y > target_y || abs(curr_y - target_y) < DROPPING_TO_CHAR_OFFSET_Y:
		ec.change_status(CLAP)

func clap_attack():
	ec.play_animation("Clap")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(CLAP_ANIMATION_DURATION, self, "change_status", CLIMB)

# Will be signalled if a character is clapped.
func clap_attack_hit(area):
	if area.is_in_group("hero"):
		area.get_node("..").stunned(CLAP_STUN_DURATION)

func climb_up(delta):
	ec.play_animation("Still")
	movement_type.set_velocity(0, -SPEED_Y)
	position += movement_type.movement(delta)

	# Back to the original y position. Start random horizontal movement.
	if position.y <= original_pos.y:
		search_for_target()
		ec.change_status(RANDOM_MOVEMENT)

func perform_random_movement(delta):
	ec.play_animation("Swing")
	if curr_rand_movement == null:
		# New random movement.
		curr_rand_movement = preload("res://Scripts/Movements/RandomMovement.gd").new(SPEED_X, 0, true, RANDOM_MOVEMENT_MIN_STEPS, RANDOM_MOVEMENT_MAX_STEPS, RANDOM_MOVEMENT_MIN_TIME_PER_STEP, RANDOM_MOVEMENT_MAX_TIME_PER_STEP)
	
	if !curr_rand_movement.movement_ended():
		# Perform random movement sequence.
		var final_pos = position + curr_rand_movement.movement(delta)
		final_pos.x = clamp(final_pos.x, original_pos.x - left_bound, original_pos.x + left_bound)
		position = final_pos
	else:
		# Search for a new target and perform MOVE.
		curr_rand_movement = null
		search_for_target()
		ec.change_status(MOVE)

func damaged(val):
	ec.change_status(CLIMB)
	ec.damaged(val)

func resume_from_damaged():
	ec.resume_from_damaged()

func stunned(duration):
	ec.change_status(CLIMB)
	ec.stunned(duration)

func resume_from_stunned():
	ec.resume_from_stunned()

func die():
	ec.die()
	status_timer = ec.cd_timer.new(DIE_ANIMATION_DURATION, self, "queue_free")

func healed(val):
	ec.healed(val)

func knocked_back(vel_x, vel_y, fade_rate):
	return

func slowed(multiplier, duration):
	return