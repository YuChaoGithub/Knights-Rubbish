extends KinematicBody2D

# Godotbos AI:
# 1. Speed walk randomly. Stand still for some time.
# 2. [1 - (health / full health)] * 100% go to 5. Remaining: 60% go to 3. 40% go to 4.
# 3. Move to the right (50%) / left (50%) edge, stand still for some time and sweep side kicks through. Go to 1.
# 4. Move to the center, fire missles. Go to 1.
# 5. Heal. When stunned or damaged, go to 6.
# 6. Throw Flaggomine. Go to 1.

enum { NONE, PRE_SPEED_WALK_STAND, SPEED_WALK, RNG_STEP, KICK_MOVE, KICK_STAND, KICK, MOVE_TO_CENTER, PREPARE_FIRE, FIRE, FIRE_LANDING_PAUSE, FIRE_LAND, HEAL, THROW_MINE_ANIM, THROW_MINE }

export(NodePath) var kick_right_pos_path
export(NodePath) var kick_left_pos_path
export(NodePath) var shoot_center_pos_path

const MAX_HEALTH = 1500
const ACTIVATE_RANGE = 2000

# Attack.
const KICK_DAMAGE = 50
const KICK_KNOCK_BACK_VEL_X = 2500
const KICK_KNOCK_BACK_VEL_Y = 0
const KICK_KNOCK_BACK_FADE_RATE = 2000
const HEAL_INTERVAL = 0.25
const HEAL_AMOUNT = 50
const KICK_DURATION = 1.0
const KICK_SPEED_X = 2000

# Movment.
const SPEED_WALK_SPEED_X = 700
const GRAVITY = 1000
const ATTACK_WALK_SPEED = 400
const RANDOM_MOVEMENT_MIN_STEPS = 3
const RANDOM_MOVEMENT_MAX_STEPS = 5
const RANDOM_MOVEMENT_MIN_TIME_PER_STEP = 0.8
const RANDOM_MOVEMENT_MAX_TIME_PER_STEP = 1.5

# Animation.
const PREPARE_SHOOT_DURATION = 1.0
const PREPARE_THROW_DURATION = 1.2
const COMPLETE_THROW_DURATION = 1.3
const RNG_STANDING_DURATION = 2.0
const KICK_STAND_DURATION = 1.0
const PRE_SPEED_WALK_STAND_DURATION = 2.5
const SHOOT_DURATION = 3.2
const SHOOT_LANDING_DURATION = 2.0

const KICK_MOVE_PERCENTAGE = 0.6

const CENTER_POS_RADIUS = 50

var status_timer = null
var heal_timer = null
var kick_timestamp = null
var kicked_targets = []
var facing = -1

# Roaming pos.
onready var kick_pos_right = get_node(kick_right_pos_path)
onready var kick_pos_left = get_node(kick_left_pos_path)
onready var shoot_center_pos = get_node(shoot_center_pos_path)

# Missles.
var missle = preload("res://Scenes/Enemies/Computer Room/Canmera Missle.tscn")
onready var missle_land_poses = [
	get_node("Missle Pos 1"),
	get_node("Missle Pos 2"),
	get_node("Missle Pos 3"),
	get_node("Missle Pos 4"),
	get_node("Missle Pos 5"),
	get_node("Missle Pos 6"),
	get_node("Missle Pos 7"),
	get_node("Missle Pos 8")
]

# Flaggomine.
var flaggomine = preload("res://Scenes/Enemies/Computer Room/Godotbos Mine.tscn")
onready var mine_spawn_pos = get_node("Animation/Mine Throw Pos")

onready var spawn_node = get_node("..")

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)

func activate():
	ec.health_bar.show_health_bar()
	ec.init_gravity_movement(GRAVITY)
	ec.init_straight_line_movement(0, 0)
	set_process(true)
	get_node("Animation/Damage Area").add_to_group("enemy_collider")
	ec.change_status(PRE_SPEED_WALK_STAND)

func _process(delta):
	if ec.not_hurt_dying_stunned():
		if ec.status == PRE_SPEED_WALK_STAND:
			pre_speed_walk_stand()
		elif ec.status == SPEED_WALK:
			speed_walk(delta)
		elif ec.status == RNG_STEP:
			rng_step_while_standing()
		elif ec.status == KICK_MOVE:
			kick_move(delta)
		elif ec.status == KICK_STAND:
			kick_stand()
		elif ec.status == KICK:
			kick(delta)
		elif ec.status == MOVE_TO_CENTER:
			move_to_center(delta)
		elif ec.status == PREPARE_FIRE:
			prepare_fire()
		elif ec.status == FIRE:
			fire()
		elif ec.status == FIRE_LANDING_PAUSE:
			fire_landing_pause()
		elif ec.status == FIRE_LAND:
			land_fire()
		elif ec.status == HEAL:
			heal_up()
		elif ec.status == THROW_MINE_ANIM:
			play_throw_mine_anim()
		elif ec.status == THROW_MINE:
			throw_mine()
	
	ec.perform_gravity_movement(delta)

func change_status(to_status):
	ec.change_status(to_status)

func pre_speed_walk_stand():
	ec.play_animation("Still")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(PRE_SPEED_WALK_STAND_DURATION, self, "change_status", SPEED_WALK)

func speed_walk(delta):
	ec.play_animation("Walk")

	if ec.random_movement == null:
		ec.init_random_movement("movement_not_ended", "movement_ended", SPEED_WALK_SPEED_X, 0, false, RANDOM_MOVEMENT_MIN_STEPS, RANDOM_MOVEMENT_MAX_STEPS, RANDOM_MOVEMENT_MIN_TIME_PER_STEP, RANDOM_MOVEMENT_MAX_TIME_PER_STEP)

	ec.perform_random_movement(delta)

func movement_not_ended(movement_dir):
	facing = movement_dir
	ec.turn_sprites_x(facing)

func movement_ended():
	ec.change_status(RNG_STEP)

func rng_step_while_standing():
	ec.play_animation("Still")
	ec.change_status(NONE)

	# 1 - health percentage, HEAL.
	var to_status = HEAL if randf() > get_health_percentage() else null
	
	# Remaining: 60% KICK. 40% SHOOT.
	if to_status == null:
		to_status = KICK_MOVE if randf() < KICK_MOVE_PERCENTAGE else MOVE_TO_CENTER

	status_timer = ec.cd_timer.new(RNG_STANDING_DURATION, self, "change_status", to_status)

func get_health_percentage():
	return float(ec.health_system.health) / float(MAX_HEALTH)

func kick_move(delta):
	ec.play_animation("Walk")
	
	# Determine whether to left/right according to facing.
	var target_x = kick_pos_right.get_global_pos().x if facing == 1 else kick_pos_left.get_global_pos().x

	ec.straight_line_movement.dx = facing * ATTACK_WALK_SPEED
	ec.perform_straight_line_movement(delta)
	
	if facing == -1 && get_global_pos().x < target_x || facing == 1 && get_global_pos().x > target_x:
		facing = -facing
		ec.turn_sprites_x(facing)
		ec.change_status(KICK_STAND)

func kick_stand():
	ec.play_animation("Still")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(KICK_STAND_DURATION, self, "change_status", KICK)

func kick(delta):
	ec.play_animation("Kick")

	if kick_timestamp == null:
		kick_timestamp = 0.0
		kicked_targets.clear()

	ec.straight_line_movement.dx = facing * KICK_SPEED_X
	ec.perform_straight_line_movement(delta)

	kick_timestamp += delta
	if kick_timestamp > KICK_DURATION:
		kick_timestamp = null
		ec.change_status(PRE_SPEED_WALK_STAND)

func on_kick_hit(area):
	if area.is_in_group("player_collider"):
		var character = area.get_node("..")
		if !(character in kicked_targets):
			kicked_targets.push_back(character)
			character.damaged(KICK_DAMAGE)
			character.stunned(KICK_DURATION)
			character.knocked_back(facing * KICK_KNOCK_BACK_VEL_X, -KICK_KNOCK_BACK_VEL_Y, KICK_KNOCK_BACK_FADE_RATE)

func move_to_center(delta):
	ec.play_animation("Walk")

	facing = sign(shoot_center_pos.get_global_pos().x - get_global_pos().x)
	ec.turn_sprites_x(facing)
	ec.straight_line_movement.dx = facing * ATTACK_WALK_SPEED
	ec.perform_straight_line_movement(delta)

	if abs(get_global_pos().x - shoot_center_pos.get_global_pos().x) < CENTER_POS_RADIUS:
		ec.change_status(PREPARE_FIRE)

func prepare_fire():
	ec.play_animation("Prepare Shoot")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(PREPARE_SHOOT_DURATION, self, "change_status", FIRE)

func fire():
	ec.play_animation("Shooting")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(SHOOT_DURATION, self, "change_status", FIRE_LANDING_PAUSE)

func fire_landing_pause():
	ec.play_animation("Still")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(SHOOT_LANDING_DURATION, self, "change_status", FIRE_LAND)

func land_fire():
	for spawn_pos in missle_land_poses:
		var new_missle = missle.instance()
		new_missle.initialize(0, 1)
		spawn_node.add_child(new_missle)
		new_missle.set_global_pos(spawn_pos.get_global_pos())

	ec.change_status(PRE_SPEED_WALK_STAND)

func heal_up():
	ec.play_animation("Heal")
	ec.change_status(NONE)

	heal_timer = ec.cd_timer.new(HEAL_INTERVAL, self, "heal_tick")

func heal_tick():
	heal_timer = null
	healed(HEAL_AMOUNT)
	heal_timer = ec.cd_timer.new(HEAL_INTERVAL, self, "heal_tick")

func interrupt_heal():
	if heal_timer != null:
		heal_timer.destroy_timer()
		heal_timer = null
	ec.change_status(THROW_MINE_ANIM)

func play_throw_mine_anim():
	ec.play_animation("Throw")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(PREPARE_THROW_DURATION, self, "change_status", THROW_MINE)

func throw_mine():
	ec.change_status(NONE)

	var new_mine = flaggomine.instance()
	new_mine.initialize(facing)
	spawn_node.add_child(new_mine)
	new_mine.set_global_pos(mine_spawn_pos.get_global_pos())

	status_timer = ec.cd_timer.new(COMPLETE_THROW_DURATION, self, "change_status", PRE_SPEED_WALK_STAND)

func damaged(val):
	var curr_anim = ec.animator.get_current_animation()
	if curr_anim == "Heal":
		interrupt_heal()
	
	ec.damaged(val, curr_anim == "Walk")

func resume_from_damaged():
	ec.resume_from_damaged()

func stunned(duration):
	if ec.animator.get_current_animation() == "Heal":
		interrupt_heal()
	else:
		ec.display_immune_text()

func healed(val):
	ec.healed(val)

func knocked_back(vel_x, vel_y, fade_rate):
	return

func slowed(multiplier, duration):
	return

func die():
	ec.die()
	ec.health_bar.drop_health_bar()