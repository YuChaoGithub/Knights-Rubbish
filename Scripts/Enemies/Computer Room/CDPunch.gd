extends KinematicBody2D

# CD Punch AI:
# 1. Detect the nearest character as its target (Searching).
# 2. Move until it is in range of the target (Walk).
# 3. Punch (Attack).
# 4. Repeat 2.

const MAX_HEALTH = 350
const ACTIVATE_RANGE = 1000
const ATTACK_RANGE_X = 350
const ATTACK_RANGE_Y = 200
const ATTACK_COOLDOWN = 1.5
const ATTACK_DAMAGE = 10
const SPEED_X = 200
const GRAVITY = 600   # (aka. gravity)
const SEARCHING_DURATION = 2.5
const DIE_ANIMATION_DURATION = 0.5
const TURN_STAGGER_MIN_DELAY = 0.2
const TURN_STAGGER_MAX_DELAY = 1.2

var activated = false
var attack_hit = false
var attack_timer = null
var search_timer = null
var turn_stagger_timer = null
var die_timer = null
var attack_target = null
var attack_on_cooldown = false
var facing = -1

var rng = preload("res://Scripts/Utils/RandomNumberGenerator.gd")
var target_detection = preload("res://Scripts/Algorithms/TargetDetection.gd")
onready var char_average_pos = get_node("../../../../Character Average Position")
onready var animator = get_node("Animation/AnimationPlayer")
onready var sprites = get_node("Animation")
onready var health_bar = get_node("Health Bar")
onready var number_spawn_pos = get_node("Number Spawn Pos")

# Horizontal movement with gravity applied.
onready var movement_type = preload("res://Scripts/Movements/HorizontalMovementWithGravity.gd").new(0, GRAVITY, self)

# Manages damage, heal, invincibility and monitors the health.
onready var health_system = preload("res://Scripts/Utils/HealthSystem.gd").new(self, MAX_HEALTH)

# Handles activate, damage, stun and animation.
onready var enemy_common = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self, ACTIVATE_RANGE, char_average_pos, animator, health_system, health_bar, number_spawn_pos, "Searching")

func _ready():
    rng.init_rand() # For staggered turn.
    set_process(true)

func _process(delta):
    if activated && enemy_common.not_hurt_dying_stunned():
        if !attack_on_cooldown && in_attack_range():
            attack()
        else:
            apply_movement(delta)

func in_attack_range():
    var target_pos = attack_target.get_global_pos()
    return abs(target_pos.x - get_global_pos().x) <= ATTACK_RANGE_X && abs(target_pos.y - get_global_pos().y) <= ATTACK_RANGE_Y

func attack():
    attack_hit = false
    attack_on_cooldown = true
    attack_timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(ATTACK_COOLDOWN, self, "reset_attack_cooldown")
    movement_type.dx = 0
    enemy_common.play_animation("Attack")

func reset_attack_cooldown():
    attack_timer = null
    movement_type.dx = facing * SPEED_X
    attack_on_cooldown = false

func apply_movement(delta):
    var target_pos = attack_target.get_global_pos()

    if target_pos.x < get_global_pos().x && facing > 0:
        # Should turn left, but stagger the turn.
        if turn_stagger_timer == null:
            turn_stagger_timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(rng.randf_range(TURN_STAGGER_MIN_DELAY, TURN_STAGGER_MAX_DELAY), self, "turn_and_set_stagger_timer_to_null")
        
    elif target_pos.x > get_global_pos().x && facing < 0:
        # Should turn right, but stagger the turn.
        if turn_stagger_timer == null:
            turn_stagger_timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(rng.randf_range(TURN_STAGGER_MIN_DELAY, TURN_STAGGER_MAX_DELAY), self, "turn_and_set_stagger_timer_to_null")
    
    # Don't perform Walk animation when attacking, stunned, hurt or searching.
    if movement_type.dx != 0:
        enemy_common.play_animation("Walk")
    
    move_to(movement_type.movement(get_global_pos(), delta))

# 1: right, -1: left.
func turn_and_set_stagger_timer_to_null():
    # turn
    facing = -facing
    sprites.set_scale(Vector2(-1 * abs(get_scale().x) * facing, get_scale().y))
    movement_type.dx = facing * abs(movement_type.dx)
    turn_stagger_timer = null

func activate():
    # Find the nearest character as its attacking target.
    attack_target = target_detection.get_nearest(self, char_average_pos.characters)
    
    activated = true

    # Become damagable.
    get_node("Animation/Damage Area").add_to_group("enemy_collider")

    # Player the searching animation. After it ends, activate (start moving and attacking).
    search_timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(SEARCHING_DURATION, self, "start_attacking_and_moving")
    enemy_common.play_animation("Searching")

# Being called when "Searching" animation is completed.
func start_attacking_and_moving():
    search_timer = null

    # Enable horizontal movement.
    movement_type.dx = facing * SPEED_X

func cancel_search_animation():
    if search_timer != null:
        search_timer.time_out()

# Called when damaged by characters' attack.
func damaged(val):
    enemy_common.damaged(val)
    cancel_search_animation()

func resume_from_damaged():
    enemy_common.resume_from_damaged()

# Called when stunned by characters' attack.
func stunned(duration):
    enemy_common.stunned(duration)
    cancel_search_animation()    
    
func resume_from_stunned():
    enemy_common.resume_from_stunned()

# Called when damaged over time by characters' attack.
func damaged_over_time(time_per_tick, total_ticks, damage_per_tick):
    health_system.change_health_over_time_by(time_per_tick, total_ticks, -damage_per_tick)

# Called when health drops below 0.
func die():
    # Can no longer be hurt.
    get_node("Animation/Damage Area").remove_from_group("enemy_collider")
    
    # Can no longer move.
    movement_type.dx = 0

    # Start die animation.
    enemy_common.play_animation_and_diable_others("Die")

    # Queue free after the animation.
    die_timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(DIE_ANIMATION_DURATION, self, "queue_free")

# Cannot be healed.
func healed(val):
    pass

func healed_over_time(time_per_tick, total_ticks, heal_per_tick):
    pass

func on_attack_hit(area):
    if !attack_hit && area.is_in_group("player_collider"):
        area.get_node("..").damaged(ATTACK_DAMAGE)
        attack_hit = true  # Avoid hitting multiple targets.