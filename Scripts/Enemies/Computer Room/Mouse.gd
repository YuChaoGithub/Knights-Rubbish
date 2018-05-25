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

export(int) var activate_range_x = 1600
export(int) var activate_range_y = 1600

signal defeated

const MAX_HEALTH = 250

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
var die_timer = null
var facing = -1

var mousy_bomb = preload("res://Scenes/Enemies/Computer Room/Mousy Bomb.tscn")
onready var mousy_spawn_pos = $"Animation/Mousy Spawn Pos"
onready var mousy_parent_node = $".."

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)

func activate():
	ec.init_gravity_movement(GRAVITY)
	set_process(true)
	ec.change_status(MOVE)
	$"Animation/Damage Area".add_to_group("enemy")

func _process(delta):
	if ec.not_hurt_dying_stunned():
		match ec.status:
			MOVE:
				perform_movement(delta)
			OPEN:
				open_lid()
			FIRE:
				spawn_mousy()
			CLOSE:
				close_lid()

	ec.perform_gravity_movement(delta)
	ec.perform_knock_back_movement(delta)

func change_status(to_status):
	ec.change_status(to_status)

func perform_movement(delta):
	ec.play_animation("Walk")
	if ec.random_movement == null:
		ec.init_random_movement("movement_not_ended", "movement_ended", SPEED_X, 0, true, RANDOM_MOVEMENT_MIN_STEPS, RANDOM_MOVEMENT_MAX_STEPS, RANDOM_MOVEMENT_MIN_TIME_PER_STEP, RANDOM_MOVEMENT_MAX_TIME_PER_STEP)

	ec.perform_random_movement(delta)

func movement_not_ended(movement_dir):
	facing = movement_dir
	ec.turn_sprites_x(facing)

func movement_ended():
	face_the_nearest_target()
	ec.change_status(OPEN)

func open_lid():
	ec.play_animation("Open Lid")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(OPEN_ANIMATION_DURATION, self, "change_status", FIRE)

func spawn_mousy():
	var new_mousy = mousy_bomb.instance()
	new_mousy.facing = facing
	mousy_parent_node.add_child(new_mousy)
	new_mousy.global_position = mousy_spawn_pos.global_position

	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(SPAWN_MOUSY_DURATION, self, "change_status", CLOSE)

func face_the_nearest_target():
	var target = ec.target_detect.get_nearest(self, ec.hero_manager.heroes)
	facing = sign(target.global_position.x - global_position.x)
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

func healed(val):
	ec.healed(val)

func knocked_back(vel_x, vel_y, fade_rate):
	ec.knocked_back(vel_x, vel_y, fade_rate)

func slowed(multiplier, duration):
	ec.slowed(multiplier, duration)

func slowed_recover(label):
	ec.slowed_recover(label)

func die():
	ec.die()
	emit_signal("defeated")
	die_timer = ec.cd_timer.new(DIE_ANIMATION_DURATION, self, "queue_free")