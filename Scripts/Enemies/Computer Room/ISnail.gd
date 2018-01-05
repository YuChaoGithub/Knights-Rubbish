extends KinematicBody2D

# iSnail AI:
# 1. Moves randomly.
# 2. Face the nearest character.
# 3. Spit 3 Hour glasses.
# 4. Repeat 1.

enum { NONE, MOVE, SPIT, SPIT_INTERVAL }

const MAX_HEALTH = 250

const ACTIVATE_RANGE = 1600

# Movement.
const SPEED_X = 50
const GRAVITY = 300
const RANDOM_MOVEMENT_MIN_STEPS = 1
const RANDOM_MOVEMENT_MAX_STEPS = 3
const RANDOM_MOVEMENT_MIN_TIME_PER_STEP = 1.5
const RANDOM_MOVEMENT_MAX_TIME_PER_STEP = 2.0

# Animation.
const DIE_ANIMATION_DURATION = 0.7

# Attack.
const ATTACK_TIMES = 3
const ATTACK_DURATION = 0.75
const ATTACK_INTERVAL = 1.0

var status_timer = null
var curr_rand_movement = null
var facing = -1
var hourglass_count = null

# Hourglass.
var hourglass = preload("res://Scenes/Enemies/Computer Room/iSnail Hourglass.tscn")
onready var hourglass_spawn_pos = get_node("Animation/Hourglass Spawn Pos")
onready var spawn_node = get_node("..")

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)

func activate():
    ec.init_gravity_movement(GRAVITY)
    set_process(true)
    ec.change_status(MOVE)
    get_node("Animation/Damage Area").add_to_group("enemy_collider")

func _process(delta):
    if ec.not_hurt_dying_stunned():
        if ec.status == MOVE:
            perform_movement(delta)
        elif ec.status == SPIT:
            spit_hourglass()
        elif ec.status == SPIT_INTERVAL:
            spit_interval()

    ec.perform_gravity_movement(delta)
    ec.perform_knock_back_movement(delta)

func change_status(to_status):
    ec.change_status(to_status)

func perform_movement(delta):
    ec.play_animation("Walk")
    if ec.random_movement == null:
        ec.init_random_movement("movement_not_ended", "movement_ended", SPEED_X, 0, false, RANDOM_MOVEMENT_MIN_STEPS, RANDOM_MOVEMENT_MAX_STEPS, RANDOM_MOVEMENT_MIN_TIME_PER_STEP, RANDOM_MOVEMENT_MAX_TIME_PER_STEP)

    ec.perform_random_movement(delta)

func movement_not_ended(movement_dir):
    facing = movement_dir
    ec.turn_sprites_x(facing)

func movement_ended():
    face_nearest_target()
    hourglass_count = 0
    ec.change_status(SPIT)

func face_nearest_target():
    var target = ec.target_detect.get_nearest(self, ec.char_average_pos.characters)
    facing = sign(target.get_global_pos().x - get_global_pos().x)
    ec.turn_sprites_x(facing)

func spit_hourglass():
    ec.play_animation("Attack")
    ec.change_status(NONE)

    var new_hourglass = hourglass.instance()
    new_hourglass.initialize(facing)
    spawn_node.add_child(new_hourglass)
    new_hourglass.set_global_pos(hourglass_spawn_pos.get_global_pos())
    
    hourglass_count += 1
    var to_status = MOVE if hourglass_count == ATTACK_TIMES else SPIT_INTERVAL
    status_timer = ec.cd_timer.new(ATTACK_DURATION, self, "change_status", to_status)

func spit_interval():
    ec.play_animation("Still")
    ec.change_status(NONE)
    status_timer = ec.cd_timer.new(ATTACK_INTERVAL, self, "change_status", SPIT)

func damaged(val):
    ec.damaged(val, ec.animator.get_current_animation() == "Walk")

func resume_from_damaged():
    ec.resume_from_damaged()

func stunned(duration):
    ec.change_status(MOVE)
    ec.stunned(duration)

func resume_from_stunned():
    ec.resume_from_stunned()

func healed(val):
    ec.healed(val)

func slowed(multiplier, duration):
    return

func knocked_back(vel_x, vel_y, fade_rate):
    ec.knocked_back(vel_x / 2, vel_y / 2, fade_rate / 2)

func die():
    ec.die()
    status_timer = ec.cd_timer.new(DIE_ANIMATION_DURATION, self, "queue_free")