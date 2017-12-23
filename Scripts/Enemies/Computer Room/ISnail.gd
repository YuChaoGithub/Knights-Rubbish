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

onready var gravity_movement = preload("res://Scripts/Movements/GravityMovement.gd").new(self, GRAVITY)
onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)

func activate():
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

    apply_gravity(delta)

func change_status(to_status):
    ec.change_status(to_status)

func apply_gravity(delta):
    move_to(gravity_movement.movement(get_global_pos(), delta))

func perform_movement(delta):
    ec.play_animation("Walk")
    if curr_rand_movement == null:
        curr_rand_movement = ec.random_movement.new(SPEED_X, 0, false, RANDOM_MOVEMENT_MIN_STEPS, RANDOM_MOVEMENT_MAX_STEPS, RANDOM_MOVEMENT_MIN_TIME_PER_STEP, RANDOM_MOVEMENT_MAX_TIME_PER_STEP)

    if curr_rand_movement.movement_ended():
        face_nearest_target()
        curr_rand_movement = null
        hourglass_count = 0
        ec.change_status(SPIT)
    else:
        var final_pos = curr_rand_movement.movement(get_global_pos(), delta)

        facing = sign(final_pos.x - get_global_pos().x)
        ec.turn_sprites_x(facing)

        move_to(final_pos)

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

func damaged_over_time(time_per_tick, total_ticks, damage_per_tick):
    ec.damaged_over_time(time_per_tick, total_ticks, damage_per_tick)

func healed(val):
    ec.healed(val)

func healed_over_time(time_per_tick, total_ticks, heal_per_tick):
    ec.healed_over_time(time_per_tick, total_ticks, heal_per_tick)

func die():
    ec.die()
    status_timer = ec.cd_timer.new(DIE_ANIMATION_DURATION, self, "queue_free")