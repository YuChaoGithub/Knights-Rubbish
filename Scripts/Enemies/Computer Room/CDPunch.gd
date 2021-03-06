extends KinematicBody2D

# CD Punch AI:
# 1. Detect the nearest character as its target (Searching).
# 2. Move until it is in range of the target (Walk).
# 3. Punch (Attack).
# 4. Repeat 2.
# ===
# When hurt or stunned, go to 2.

enum { NONE, SEARCH, MOVE, ATTACK }

signal defeated

export(int) var activate_range_x = 25000
export(int) var activate_range_y = 25000

const MAX_HEALTH = 200

# Attack.
const ATTACK_RANGE_X = 300
const ATTACK_RANGE_Y = 200
const ATTACK_DAMAGE = 12
const KNOCK_BACK_VEL_X = 750
const KNOCK_BACK_FADE_RATE = 1500
const KNOCK_BACK_VEL_Y = 0

# Movement.
const SPEED_X = 200
const GRAVITY = 600
const TURN_STAGGER_MIN_DELAY = 0.2
const TURN_STAGGER_MAX_DELAY = 1.2

# Animation.
const SEARCHING_DURATION = 2.0
const DIE_ANIMATION_DURATION = 0.5
const ATTACK_ANIMATION_DURATION = 0.65

var status_timer = null
var die_timer = null
var turn_stagger_timer = null
var attack_target = null
var facing = -1

onready var punch_particles = $"Animation/PunchParticles"

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)

func activate():
    ec.init_gravity_movement(GRAVITY)
    ec.init_straight_line_movement(facing * SPEED_X, 0)
    attack_target = ec.target_detect.get_nearest(self, ec.hero_manager.heroes)
    set_process(true)
    ec.change_status(SEARCH)
    $"Animation/Damage Area".add_to_group("enemy")

func _process(delta):
    if ec.not_hurt_dying_stunned():
        match ec.status:
            SEARCH:
                search_for_target()
            MOVE:
                apply_movement(delta)
            ATTACK:
                attack()

    ec.perform_gravity_movement(delta)
    ec.perform_knock_back_movement(delta)

func change_status(to_status):
    ec.change_status(to_status)

func search_for_target():
    ec.play_animation("Searching")

    attack_target = ec.target_detect.get_nearest(self, ec.hero_manager.heroes)

    ec.change_status(NONE)
    status_timer = ec.cd_timer.new(SEARCHING_DURATION, self, "change_status", MOVE)

func apply_movement(delta):
    ec.play_animation("Walk")

    var target_pos = attack_target.global_position

    if target_pos.x < global_position.x && facing > 0:
        # Should turn left, but stagger the turn.
        if turn_stagger_timer == null:
            turn_stagger_timer = ec.cd_timer.new(ec.rng.randf_range(TURN_STAGGER_MIN_DELAY, TURN_STAGGER_MAX_DELAY), self, "turn_and_set_stagger_timer_to_null")
        
    elif target_pos.x > global_position.x && facing < 0:
        # Should turn right, but stagger the turn.
        if turn_stagger_timer == null:
            turn_stagger_timer = ec.cd_timer.new(ec.rng.randf_range(TURN_STAGGER_MIN_DELAY, TURN_STAGGER_MAX_DELAY), self, "turn_and_set_stagger_timer_to_null")
    
    ec.perform_straight_line_movement(delta)

    # If the target is in attack range, switch to attack state.
    if abs(target_pos.x - global_position.x) <= ATTACK_RANGE_X && abs(target_pos.y - global_position.y) <= ATTACK_RANGE_Y:
        ec.change_status(ATTACK)

func attack():
    ec.play_animation("Attack")

    ec.change_status(NONE)
    status_timer = ec.cd_timer.new(ATTACK_ANIMATION_DURATION, self, "change_status", SEARCH)

# 1: right, -1: left.
func turn_and_set_stagger_timer_to_null():
    # turn
    facing = -facing
    ec.turn_sprites_x(facing)
    ec.straight_line_movement.dx = facing * abs(ec.straight_line_movement.dx)
    turn_stagger_timer = null

# Called when damaged by characters' attack.
func damaged(val):
    ec.change_status(MOVE)
    ec.damaged(val)

func resume_from_damaged():
    ec.resume_from_damaged()

# Called when stunned by characters' attack.
func stunned(duration):
    ec.change_status(MOVE)
    ec.stunned(duration)   
    
func resume_from_stunned():
    ec.resume_from_stunned()

func slowed(multiplier, duration):
    ec.slowed(multiplier, duration)
    
func slowed_recover(label):
    ec.slowed_recover(label)

func knocked_back(vel_x, vel_y, fade_rate):
    ec.knocked_back(vel_x, vel_y, fade_rate)

# Called when health drops below 0.
func die():
    ec.die()
    emit_signal("defeated")
    die_timer = ec.cd_timer.new(DIE_ANIMATION_DURATION, self, "queue_free")

func healed(val):
    ec.healed(val)

func on_attack_hit(area):
    if area.is_in_group("hero"):
        punch_particles.emitting = true
        
        var character = area.get_node("..")
        character.damaged(ATTACK_DAMAGE)
        character.knocked_back(facing * KNOCK_BACK_VEL_X, KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)