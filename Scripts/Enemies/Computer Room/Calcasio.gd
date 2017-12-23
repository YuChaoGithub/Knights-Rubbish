extends KinematicBody2D

# Calcasio AI:
# 1. Move for a centain duration.
# 2. Face the nearest character.
# 3. Type random numbers. Shoot.
# 4. Repeat 1.
# ===
# When hurt or stunned, go to 1.
# Don't play hurt animation when typing or shooting.

enum { NONE, MOVE, TYPE, SHOOT }

const MAX_HEALTH = 200

const ACTIVATE_RANGE = 2000

# Movement.
const SPEED_X = 150
const GRAVITY = 600
const RANDOM_MOVEMENT_MIN_STEPS = 3
const RANDOM_MOVEMENT_MAX_STEPS = 5
const RANDOM_MOVEMENT_MIN_TIME_PER_STEP = 0.3
const RANDOM_MOVEMENT_MAX_TIME_PER_STEP = 0.8

# Animation.
const DIE_ANIMATION_DURATION = 0.5
const SINGLE_TYPE_DURATION = 0.2
const TYPING_ANIMATION_DURATION = 2
const SHOOT_ANIMATION_DURATION = 1

const TYPE_MIN_DIGIT = 1
const TYPE_MAX_DIGIT = 7

var status_timer = null
var curr_rand_movement = null
var facing = -1

var spawned_bullets = []
var bullet_spawning_timer = null

# Bullet spawn.
var mt_timer = preload("res://Scripts/Utils/MultiTickTimer.gd")
var bullet = preload("res://Scenes/Enemies/Computer Room/Calcasio Bullet.tscn")
onready var bullet_spawn_pos = [
    get_node("Animation/Bullet Spawn Pos/0"),
    get_node("Animation/Bullet Spawn Pos/1"),
    get_node("Animation/Bullet Spawn Pos/2"),
    get_node("Animation/Bullet Spawn Pos/3"),
    get_node("Animation/Bullet Spawn Pos/4"),
    get_node("Animation/Bullet Spawn Pos/5")
]
onready var bullet_type_animator = get_node("Animation/Body/Number Buttons/AnimationPlayer")
onready var spawn_node = get_node("..")

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)
onready var gravity_movement = ec.gravity_movement.new(self, GRAVITY)

func activate():
    set_process(true)
    ec.change_status(MOVE)
    get_node("Animation/Damage Area").add_to_group("enemy_collider")

func _process(delta):
    if ec.not_hurt_dying_stunned():
        if ec.status == MOVE:
            apply_random_movement(delta)
        elif ec.status == TYPE:
            type_digit_bullets()
        elif ec.status == SHOOT:
            shoot_digit_bullets()
        
    apply_gravity(delta)

func change_status(to_status):
    ec.change_status(to_status)

func apply_gravity(delta):
    move_to(gravity_movement.movement(get_global_pos(), delta))

func apply_random_movement(delta):
    ec.play_animation("Walk")
    if curr_rand_movement == null:
        # New random movement.
        curr_rand_movement = ec.random_movement.new(SPEED_X, 0, true, RANDOM_MOVEMENT_MIN_STEPS, RANDOM_MOVEMENT_MAX_STEPS, RANDOM_MOVEMENT_MIN_TIME_PER_STEP, RANDOM_MOVEMENT_MAX_TIME_PER_STEP)

    if !curr_rand_movement.movement_ended():
        # Existing random movement.
        var final_pos = curr_rand_movement.movement(get_global_pos(), delta)
        move_to(final_pos)
    else:
        # Random movement ended.
        detect_and_face_the_nearest_target()
        curr_rand_movement = null
        ec.change_status(TYPE)

func detect_and_face_the_nearest_target():
    var attack_target = ec.target_detect.get_nearest(self, ec.char_average_pos.characters)
    facing = -1 if attack_target.get_global_pos().x < get_global_pos().x else 1
    ec.turn_sprites_x(facing)

func type_digit_bullets():
    ec.play_animation("Typing")
    ec.change_status(NONE)
    status_timer = ec.cd_timer.new(TYPING_ANIMATION_DURATION, self, "change_status", SHOOT)

    # Bullet spawning.
    bullet_spawning_timer = mt_timer.new(false, SINGLE_TYPE_DURATION, bullet_spawn_pos.size(), self, "spawn_bullet")

func spawn_bullet():
    var digit = ec.rng.randi_range(TYPE_MIN_DIGIT, TYPE_MAX_DIGIT + 1)
    bullet_type_animator.play(str(digit))

    var new_bullet = bullet.instance()
    new_bullet.initialize(digit, facing)
    spawn_node.add_child(new_bullet)
    new_bullet.set_global_pos(bullet_spawn_pos[spawned_bullets.size()].get_global_pos())
    spawned_bullets.push_back(new_bullet)

    # Last tick.
    if spawned_bullets.size() == bullet_spawn_pos.size():
        bullet_spawning_timer = null

func shoot_digit_bullets():
    ec.play_animation("Shoot")
    
    for bullet in spawned_bullets:
        bullet.start_travel()

    spawned_bullets.clear()

    ec.change_status(NONE)
    status_timer = ec.cd_timer.new(SHOOT_ANIMATION_DURATION, self, "change_status", MOVE)

func cancel_bullet_spawning():
    if bullet_spawning_timer != null:
        bullet_spawning_timer.destroy_timer()
        bullet_spawning_timer = null

    for bullet in spawned_bullets:
        bullet.queue_free()

    spawned_bullets.clear()

func damaged(val):
    var curr_anim = ec.animator.get_current_animation()
    var play_anim = curr_anim != "Typing" && curr_anim != "Shoot"
    ec.damaged(val, play_anim)

func resume_from_damaged():
    ec.resume_from_damaged()

func damaged_over_time(time_per_tick, total_ticks, damage_per_tick):
    ec.damaged_over_time(time_per_tick, total_ticks, damage_per_tick)

func healed(val):
    ec.healed(val)

func healed_over_time(time_per_tick, total_ticks, heal_per_tick):
    ec.healed_over_time(time_per_tick, total_ticks, heal_per_tick)

func stunned(duration):
    cancel_bullet_spawning()
    ec.change_status(MOVE)
    ec.stunned(duration)

func resume_from_stunned():
    ec.resume_from_stunned()

func die():
    cancel_bullet_spawning()
    ec.die()
    status_timer = ec.cd_timer.new(DIE_ANIMATION_DURATION, self, "queue_free")