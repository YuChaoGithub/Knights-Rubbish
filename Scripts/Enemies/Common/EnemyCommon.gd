const CHECK_ACTIVATE_IN_SECS_MIN = 0.2
const CHECK_ACTIVATE_IN_SECS_MAX = 0.6
const DAMAGE_NUMBER_COLOR = Color(1.0, 0.0, 0.0)
const HEAL_NUMBER_COLOR = Color(0.0, 100.0 / 255.0, 0.0)
const STUNNED_TEXT_COLOR = Color(1.0, 1.0, 0.0)
const IMMUNE_TEXT_COLOR = Color(255.0 / 255.0, 200.0 / 255.0, 0.0 / 255.0)
const HURT_ANIM_DURATION = 0.3
const HEALTH_MULTIPLIER_PER_PLAYER = 1

# Some commonly used scripts.
var rng = preload("res://Scripts/Utils/RandomNumberGenerator.gd")
var num_indicator = preload("res://Scenes/Utils/Numbers/Number Indicator.tscn")
var target_detect = preload("res://Scripts/Algorithms/TargetDetection.gd")
var cd_timer = preload("res://Scripts/Utils/CountdownTimer.gd")

var node
var status
var activate_range_x
var activate_range_y
var hero_manager
var animator
var health_system
var health_bar
var number_spawn_pos
var sprites
var is_kinematic_body
var slowed_label
var curr_anim_key = ""

var fade_in_timer = null

var knock_back_fade_rate = 0
var knock_back_dx = 0
var knock_back_dy = 0
var slowed_timers = {} # Label -> {timer, multiplier, movements[]}
var slowed_timer_label = 0

var gravity_movement = null
var straight_line_movement = null
var random_movement = null
var random_movement_not_ended_func = null
var random_movement_ended_func = null

var disable_animation = false
var activate_timer = null
var hurt_timer = null
var stun_timer = null

func _init(node, default_status = 0):
    node.set_process(false)

    self.node = node
    self.status = default_status
    self.activate_range_x = node.activate_range_x
    self.activate_range_y = node.activate_range_y
    self.hero_manager = node.get_node("../../HeroManager")
    self.animator = node.get_node("Animation/AnimationPlayer")
    self.health_system = preload("res://Scripts/Utils/HealthSystem.gd").new(node, int(node.MAX_HEALTH * hero_manager.heroes.size() * HEALTH_MULTIPLIER_PER_PLAYER))
    self.health_bar = node.get_node("Health Bar")
    self.number_spawn_pos = node.get_node("Number Spawn Pos")
    self.sprites = node.get_node("Animation")
    self.is_kinematic_body = node.is_class("KinematicBody2D")
    self.slowed_label = preload("res://Scenes/Enemies/Enemy Slowed Icon.tscn").instance()
    
    # Slowed label.
    number_spawn_pos.add_child(slowed_label)
    slowed_label.visible = false

    # Set up check activate timer.
    activate_timer = Timer.new()
    activate_timer.one_shot = false
    activate_timer.wait_time = rng.randf_range(CHECK_ACTIVATE_IN_SECS_MIN, CHECK_ACTIVATE_IN_SECS_MAX)
    activate_timer.connect("timeout", self, "perform_activate_check")
    node.add_child(activate_timer)
    activate_timer.start()

func change_status(to_status):
    status = to_status
    if node.status_timer != null:
        node.status_timer.destroy_timer()
        node.status_timer = null

func perform_activate_check():
    if hero_manager.in_range_of(node.global_position, activate_range_x, activate_range_y):
        node.call("activate")
        activate_timer.stop()
        activate_timer.queue_free()

# Gravity Movement.
func init_gravity_movement(gravity):
    gravity_movement = preload("res://Scripts/Movements/GravityMovement.gd").new(node, gravity)

func perform_gravity_movement(delta):
    gravity_movement.move(delta)

# Straight Line Movement.
func init_straight_line_movement(dx, dy):
    straight_line_movement = preload("res://Scripts/Movements/StraightLineMovement.gd").new(dx, dy)

func perform_straight_line_movement(delta):
    if is_kinematic_body:
        node.move_and_collide(straight_line_movement.movement(delta))
    else:
        node.global_position += straight_line_movement.movement(delta)

# Random Movement.
func init_random_movement(movement_not_ended_func, movement_ended_func, dx, dy, always_change_dir = true, min_steps = 2, max_steps = 4, min_time_per_step = 0.25, max_time_per_step = 0.75):
    random_movement_not_ended_func = movement_not_ended_func
    random_movement_ended_func = movement_ended_func
    random_movement = preload("res://Scripts/Movements/RandomMovement.gd").new(dx, dy, always_change_dir, min_steps, max_steps, min_time_per_step, max_time_per_step)

func perform_random_movement(delta):
    if random_movement.movement_ended():
        node.call(random_movement_ended_func)
        discard_random_movement()
    else:
        var original_pos = node.global_position

        if is_kinematic_body:
            node.move_and_collide(random_movement.movement(delta))
        else:
            node.global_position += random_movement.movement(delta)
        
        node.call(random_movement_not_ended_func, sign(node.global_position.x - original_pos.x))

func discard_random_movement():
    random_movement = null
    random_movement_not_ended_func = null
    random_movement_ended_func = null

func play_animation(key):
    if !disable_animation && curr_anim_key != key:
        curr_anim_key = key
        animator.play(key)

func play_animation_and_disble_others(key):
    disable_animation = true
    animator.play(key)

func turn_sprites_x(facing):
    if facing != 0:
        sprites.scale = Vector2(-1 * abs(sprites.scale.x) * facing, sprites.scale.y)

func not_hurt_dying_stunned():
    return curr_anim_key != "Hurt" && curr_anim_key != "Die" && curr_anim_key != "Stunned"

func change_and_refill_full_health(full_health):
    health_system.full_health = full_health
    health_system.health = full_health

func slowed(multiplier, duration):
    var slow_timer = cd_timer.new(duration, node, "slowed_recover", slowed_timer_label)
    
    var movements = []
    if random_movement != null:
        random_movement.dx *= multiplier
        random_movement.dy *= multiplier
        movements.push_back(weakref(random_movement))
    
    if straight_line_movement != null:
        straight_line_movement.dx *= multiplier
        straight_line_movement.dy *= multiplier
        movements.push_back(weakref(straight_line_movement))

    slowed_timers[slowed_timer_label] = {
        timer = slow_timer,
        multiplier = multiplier,
        movements = movements
    }
    slowed_timer_label += 1

    slowed_label.visible = true
    slowed_label.get_node("AnimationPlayer").play("Pop")

func slowed_recover(label):
    var slow_data = slowed_timers[label]
    
    for movement in slow_data.movements:
        var movement_type = movement.get_ref()
        if movement_type != null:
            movement_type.dx /= slow_data.multiplier
            movement_type.dy /= slow_data.multiplier

    slowed_timers.erase(label)

    if slowed_timers.size() == 0:
        slowed_label.visible = false

func knocked_back(vel_x, vel_y, fade_rate):
    knock_back_dx = vel_x
    knock_back_dy = vel_y
    knock_back_fade_rate = fade_rate

    # Reset gravity movement for knocking up.
    if gravity_movement != null:
        gravity_movement.dy = 0

func perform_knock_back_movement(delta):
    knock_back_dx = sign(knock_back_dx) * max(0, abs(knock_back_dx) - abs(delta * knock_back_fade_rate))
    knock_back_dy = sign(knock_back_dy) * max(0, abs(knock_back_dy) - abs(delta * knock_back_fade_rate))

    var rel_movement = Vector2(knock_back_dx, knock_back_dy) * delta
    if is_kinematic_body:
        node.move_and_collide(rel_movement)
    else:
        node.global_position += rel_movement
    
func damaged(val, play_hurt_animation = true):
    health_system.change_health_by(-val)

    # Damage number indicator.
    var number = num_indicator.instance()
    number.initialize(val, DAMAGE_NUMBER_COLOR, number_spawn_pos, node)

    # If there exists a hurt timer, destroy it.
    # (Don't trigger timeout event.)
    if hurt_timer != null:
        hurt_timer.destroy_timer()
        hurt_timer = null

    # Won't play hurt animation if it is stunned.
    if (curr_anim_key == "Hurt" || play_hurt_animation) && curr_anim_key != "Stunned":
        play_animation("Hurt")
        hurt_timer = cd_timer.new(HURT_ANIM_DURATION, node, "resume_from_damaged")

    # Show health bar.
    health_bar.set_health_bar_and_show(float(health_system.health) / float(health_system.full_health))

# NOTE that this function should be called by the node.
func resume_from_damaged():
    play_animation("Still")
    hurt_timer = null

func stunned(duration):
    # Cancel hurt timer so that it won't recover to Still animation.
    if hurt_timer != null:
        hurt_timer.destroy_timer()
        hurt_timer = null

    # Stunned text (number indicator).
    var stunned_text = num_indicator.instance()
    stunned_text.initialize(-1, STUNNED_TEXT_COLOR, number_spawn_pos, node)
    
    # If the node is currently stunned, Destroy the previous effect and apply the new one.
    if stun_timer != null:
        stun_timer.destroy_timer()
        stun_timer = null
    
    play_animation("Stunned")
    stun_timer = cd_timer.new(duration, node, "resume_from_stunned")

# NOTE that this function should be called by the node.
func resume_from_stunned():
    play_animation("Still")
    stun_timer = null

func display_immune_text():
    var immune_text = num_indicator.instance()
    immune_text.initialize(-2, IMMUNE_TEXT_COLOR, number_spawn_pos, node)

func healed(val):
    # Dead already.
    if health_system.health <= 0:
        return

    health_system.change_health_by(val)

    # Damage number indicator.
    var number = num_indicator.instance()
    number.initialize(val, HEAL_NUMBER_COLOR, number_spawn_pos, node)

    # Show health bar.
    health_bar.set_health_bar_and_show(float(health_system.health) / float(health_system.full_health))

func die():
    slowed_label.visible = false

    # Can't be hurt any more.
    node.get_node("Animation/Damage Area").remove_from_group("enemy")
    
    # No other movement or stuff.
    change_status(node.NONE)
    
    # Play die animation.
    play_animation_and_disble_others("Die")