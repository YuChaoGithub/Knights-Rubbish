extends KinematicBody2D

# Eelo Puncher AI:
# 1. Roam randomly.
# 2. If a character is in range, dash and punch!!
# 3. Run away from the player.
# 4. If health < x%, move to healing fountain to heal until health > y%.
# 5. Go to 1.
# ===
# Don't play hurt animation while punching.
# When stunned, go to 1.

signal defeated

enum { NONE, LANDING, ROAM, DASH, PUNCH, INIT_FLEE, FLEE, SEEK_HEAL, HEALING }

export(int) var activate_range_x = 25000
export(int) var activate_range_y = 25000

const MAX_HEALTH = 200

# Attack.
const ATTACK_RANGE_X = 125
const ATTACK_RANGE_Y = 200
const DAMAGE = 20
const KNOCK_BACK_VEL_X = 600
const KNOCK_BACK_VEL_Y = 0
const KNOCK_BACK_FADE_RATE = 1000

# Movement.
const SPEED_X = 300
const GRAVITY = 600
const DASH_RANGE = 700
const DASH_SPEED = 600
const FLEE_SPEED = 500
const FLEE_MIN_DURATION = 0.6
const FLEE_MAX_DURATION = 1.2
const RANDOM_MOVEMENT_STEPS = 5
const RANDOM_MOVEMENT_MIN_TIME_PER_STEP = 1.0
const RANDOM_MOVEMENT_MAX_TIME_PER_STEP = 2.0

const HEAL_DURATION = 2.5
const SEEK_HEAL_PERCENTAGE = 0.4
const HEAL_RANGE = 175

# Animation.
const DIE_ANIMATION_DURATION = 0.5
const PUNCH_ANIMATION_DURATION = 2.4

var status_timer = null
var die_timer = null
var attack_target = null
var facing = -1

var heal_pos

onready var leftpunch_particles = $"Animation/LeftPunchParticles"
onready var rightpunch_particles = $"Animation/RightPunchParticles"

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)

onready var hit_audio = $Audio/Hit

func activate():
	ec.init_gravity_movement(GRAVITY)
	ec.init_straight_line_movement(0, 0)
	get_heal_pos()
	set_process(true)
	ec.change_status(LANDING)
	$"Animation/Damage Area".add_to_group("enemy")

func get_heal_pos():
	var nearest_distance = 1000000000
	for heal_fountain in get_node("../HealingFountains").get_children():
		var pos = heal_fountain.global_position
		var distance = pos.distance_squared_to(global_position)
		if distance < nearest_distance:
			heal_pos = pos
			nearest_distance = distance

func _process(delta):
	if ec.not_hurt_dying_stunned():
		match ec.status:
			LANDING:
				check_landing()
			ROAM:
				roam_randomly(delta)
			DASH:
				dash_to_target(delta)
			PUNCH:
				punch()
			INIT_FLEE:
				init_flee()
			FLEE:
				flee(delta)
			SEEK_HEAL:
				seek_heal(delta)
			HEALING:
				heal_up()

	ec.perform_gravity_movement(delta)
	ec.perform_knock_back_movement(delta)

func change_status(to_status):
	ec.change_status(to_status)

func check_landing():
	ec.play_animation("Landing")
	if ec.gravity_movement.is_landed:
		ec.change_status(ROAM)

func roam_randomly(delta):
	ec.play_animation("Walk")
	if ec.random_movement == null:
		ec.init_random_movement("movement_not_ended", "movement_ended", SPEED_X, 0, true, RANDOM_MOVEMENT_STEPS, RANDOM_MOVEMENT_STEPS, RANDOM_MOVEMENT_MIN_TIME_PER_STEP, RANDOM_MOVEMENT_MAX_TIME_PER_STEP)

	ec.perform_random_movement(delta)

	# Check if a character is in dash range.
	for character in ec.hero_manager.heroes:
		if abs(character.global_position.x - global_position.x) <= DASH_RANGE:
			attack_target = character
			ec.change_status(DASH)
			ec.discard_random_movement()
			return

func movement_not_ended(movement_dir):
	facing = movement_dir
	ec.turn_sprites_x(facing)

func movement_ended():
	return

func dash_to_target(delta):
	ec.play_animation("Walk")
	
	facing = sign(attack_target.global_position.x - global_position.x)
	ec.turn_sprites_x(facing)
	ec.straight_line_movement.dx = facing * DASH_SPEED
	ec.perform_straight_line_movement(delta)

	# Check if in attack range.
	if abs(attack_target.global_position.x -global_position.x) <= ATTACK_RANGE_X:
		if abs(attack_target.global_position.y -global_position.y) <= ATTACK_RANGE_Y:
			ec.change_status(PUNCH)
		else: # If the hero isn't in the y range, roam again.
			ec.change_status(SEEK_HEAL)

func punch():
	ec.play_animation("Punch")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(PUNCH_ANIMATION_DURATION, self, "change_status", INIT_FLEE)

func on_left_attack_hit(area):
	if area.is_in_group("hero"):
		leftpunch_particles.emitting = true
		apply_attack(area.get_node(".."), facing)

func on_right_attack_hit(area):
	if area.is_in_group("hero"):
		rightpunch_particles.emitting = true
		apply_attack(area.get_node(".."), -facing)

func apply_attack(character, dir):
	hit_audio.play()
	
	character.damaged(DAMAGE)
	character.knocked_back(dir * KNOCK_BACK_VEL_X, KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)

func init_flee():
	ec.change_status(FLEE)

	var to_status = ROAM if get_health_percentage() > SEEK_HEAL_PERCENTAGE else SEEK_HEAL
	status_timer = ec.cd_timer.new(ec.rng.randf_range(FLEE_MIN_DURATION, FLEE_MAX_DURATION), self, "change_status", to_status)

func flee(delta):
	ec.play_animation("Walk")

	facing = sign(global_position.x - attack_target.global_position.x)
	ec.turn_sprites_x(facing)
	ec.straight_line_movement.dx = facing * FLEE_SPEED
	ec.perform_straight_line_movement(delta)

func get_health_percentage():
	return float(ec.health_system.health) / float(MAX_HEALTH)

func seek_heal(delta):
	ec.play_animation("Walk")

	facing = sign(heal_pos.x - global_position.x)
	ec.straight_line_movement.dx = facing * FLEE_SPEED
	ec.turn_sprites_x(facing)
	ec.perform_straight_line_movement(delta)

	if abs(global_position.x - heal_pos.x) <= HEAL_RANGE:
		ec.change_status(HEALING)

func heal_up():
	ec.play_animation("Healing")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(HEAL_DURATION, self, "change_status", ROAM)

func damaged(val):
	ec.damaged(val, ec.animator.current_animation != "Punch")
	
func resume_from_damaged():
	ec.resume_from_damaged()

func stunned(duration):
	ec.change_status(ROAM)
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
	emit_signal("defeated")
	ec.die()
	die_timer = ec.cd_timer.new(DIE_ANIMATION_DURATION, self, "queue_free")
	get_node("/root/Steamworks").eelo_killed()