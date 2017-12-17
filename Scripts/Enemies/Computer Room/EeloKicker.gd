extends KinematicBody2D

# Eelo Kicker AI:
# 1. Roam randomly.
# 2. When a character is in range, move towards the nearest character.
# 3. If a character is in range, kick!!
# 4. Run to the healing fountain and heal for some time.
# 5. Go to 1.
# ===
# Don't play hurt animation while kicking.
# When stunned, go to 1.

enum { NONE, ROAM, MOVE_TO_CHAR, KICK, SEEK_HEAL, HEALING }

export(NodePath) var fountain_path

const MAX_HEALTH = 150

const ACTIVATE_RANGE = 1000

# Attack.
const ATTACK_RANGE_X = 100
const ATTACK_RANGE_Y = 250
const DAMAGE = 40
const KNOCK_BACK_VEL_X = 700
const KNOCK_BACK_VEL_Y = 250
const KNOCK_BACK_FADE_RATE = 1100

# Movement.
const SPEED_X = 200
const GRAVITY = 600
const CHASE_RANGE = 700
const SEEK_HEAL_SPEED = 300
const HEAL_DURATION = 2.2
const RANDOM_MOVEMENT_STEP = 5
const RANDOM_MOVEMENT_MIN_TIME_PER_STEP = 1.5
const RANDOM_MOVEMENT_MAX_TIME_PER_STEP = 2.5

const HEAL_RANGE = 175

# Animation.
const DIE_ANIMATION_DURATION = 0.8
const SINGLE_KICK_DURATION = 0.6

var status_timer = null
var kick_timer = null
var kick_sequence = ["Left Kick", "Right Kick", "Double Kick"]
var curr_rand_movement = null
var attack_target = null
var facing = -1

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)
onready var gravity_movement = ec.gravity_movement.new(self, GRAVITY)
onready var horizontal_movement = ec.straight_line_movement.new(0, 0)

onready var heal_pos = get_node(fountain_path)

func activate():
	set_process(true)
	ec.change_status(ROAM)
	get_node("Animation/Damage Area").add_to_group("enemy_collider")

func _process(delta):
	if ec.not_hurt_dying_stunned():
		if ec.status == ROAM:
			roam_randomly(delta)
		elif ec.status == MOVE_TO_CHAR:
			move_to_attack_target(delta)
		elif ec.status == KICK:
			kick()
		elif ec.status == SEEK_HEAL:
			move_to_healing_fountain(delta)
		elif ec.status == HEALING:
			heal_up()

	apply_gravity(delta)

func change_status(to_status):
	ec.change_status(to_status)

func apply_gravity(delta):
	move_to(gravity_movement.movement(get_global_pos(), delta))

func roam_randomly(delta):
	ec.play_animation("Walk")
	if curr_rand_movement == null:
		curr_rand_movement = ec.random_movement.new(SPEED_X, 0, true, RANDOM_MOVEMENT_STEP, RANDOM_MOVEMENT_STEP, RANDOM_MOVEMENT_MIN_TIME_PER_STEP, RANDOM_MOVEMENT_MAX_TIME_PER_STEP)

	if curr_rand_movement.movement_ended():
		curr_rand_movement = null
	else:
		var final_pos = curr_rand_movement.movement(get_global_pos(), delta)

		if final_pos.x < get_global_pos().x:
			facing = -1
		elif final_pos.x > get_global_pos().x:
			facing = 1
		ec.turn_sprites_x(facing)

		move_to(final_pos)

	for character in ec.char_average_pos.characters:
		if abs(character.get_global_pos().x - get_global_pos().x) <= CHASE_RANGE:
			attack_target = character
			ec.change_status(MOVE_TO_CHAR)
			curr_rand_movement = null
			return

func move_to_attack_target(delta):
	ec.play_animation("Walk")

	facing = sign(attack_target.get_global_pos().x - get_global_pos().x)
	ec.turn_sprites_x(facing)
	horizontal_movement.dx = facing * SPEED_X
	move_to(horizontal_movement.movement(get_global_pos(), delta))

	if abs(attack_target.get_global_pos().x - get_global_pos().x) <= ATTACK_RANGE_X && abs(attack_target.get_global_pos().y - get_global_pos().y) <= ATTACK_RANGE_Y:
		ec.change_status(KICK)

func kick():
	ec.change_status(NONE)
	swap_kick_sequence_randomly()
	perform_kick_sequence(0)
	
# Actually, only pick one pair to swap.
# Also, the randomness isn't distributed equally. But who cares.
func swap_kick_sequence_randomly():
	var i = ec.rng.randi_range(1, kick_sequence.size())
	var j = ec.rng.randi_range(0, i)
	var temp = kick_sequence[i]
	kick_sequence[i] = kick_sequence[j]
	kick_sequence[j] = temp

func perform_kick_sequence(index):
	if index >= kick_sequence.size():
		ec.change_status(SEEK_HEAL)
		return

	ec.play_animation(kick_sequence[index])
	kick_timer = ec.cd_timer.new(SINGLE_KICK_DURATION, self, "perform_kick_sequence", index + 1)

func on_right_kick_hit(area):
	if area.is_in_group("player_collider"):
		apply_kick_damage(area.get_node(".."), -facing)

func on_left_kick_hit(area):
	if area.is_in_group("player_collider"):
		apply_kick_damage(area.get_node(".."), facing)

func apply_kick_damage(character, dir):
	character.damaged(DAMAGE)
	character.knocked_back(dir * KNOCK_BACK_VEL_X, -KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)

func move_to_healing_fountain(delta):
	ec.play_animation("Walk")

	facing = sign(heal_pos.get_global_pos().x - get_global_pos().x)
	horizontal_movement.dx = facing * SEEK_HEAL_SPEED
	ec.turn_sprites_x(facing)
	move_to(horizontal_movement.movement(get_global_pos(), delta))

	if abs(get_global_pos().x - heal_pos.get_global_pos().x) <= HEAL_RANGE:
		ec.change_status(HEALING)

func heal_up():
	ec.play_animation("Healing")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(HEAL_DURATION, self, "change_status", ROAM)

func damaged(val):
	ec.damaged(val, ec.animator.get_current_animation() != "Walk")

func resume_from_damaged():
	ec.resume_from_damaged()

func stunned(duration):
	ec.change_status(ROAM)
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