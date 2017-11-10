const CHECK_ACTIVATE_IN_SECS = 1
const DAMAGE_NUMBER_COLOR = Color(1.0, 0.0, 0.0)
const HEAL_NUMBER_COLOR = Color(0.0, 100.0 / 255.0, 0.0)
const STUNNED_TEXT_COLOR = Color(1.0, 1.0, 0.0)
const HURT_ANIM_DURATION = 0.3

var number_indicator = preload("res://Scenes/Utils/Numbers/Number Indicator.tscn")
var countdown_timer = preload("res://Scripts/Utils/CountdownTimer.gd")

var node
var activate_range_squared
var char_average_pos
var animator
var health_system
var health_bar
var number_spawn_pos
var still_anim_name

var disable_animation = false
var activate_timer = null
var hurt_timer = null
var stun_timer = null

func _init(node, activate_range, char_average_pos, animator, health_system, health_bar, number_spawn_pos, still_anim_name):
    self.node = node
    self.activate_range_squared = activate_range * activate_range
    self.char_average_pos = char_average_pos
    self.animator = animator
    self.health_system = health_system
    self.health_bar = health_bar
    self.number_spawn_pos = number_spawn_pos
    self.still_anim_name = still_anim_name

    # Set up check activate timer.
    activate_timer = Timer.new()
    activate_timer.set_one_shot(false)
    activate_timer.set_wait_time(CHECK_ACTIVATE_IN_SECS)
    activate_timer.connect("timeout", self, "perform_activate_check")
    node.add_child(activate_timer)
    activate_timer.start()

func perform_activate_check():
    if node.get_global_pos().distance_squared_to(char_average_pos.get_global_pos()) <= activate_range_squared:
        node.call("activate")
        activate_timer.stop()
        activate_timer.queue_free()

func play_animation(key):
    if !disable_animation && animator.get_current_animation() != key:
        animator.play(key)

func play_animation_and_diable_others(key):
    disable_animation = true
    animator.play(key)

func not_hurt_dying_stunned():
    var key = animator.get_current_animation()
    return key != "Hurt" && key != "Die" && key != "Stunned"

func damaged(val):
    health_system.change_health_by(-val)

    # Damage number indicator.
    var number = number_indicator.instance()
    number.initialize(val, DAMAGE_NUMBER_COLOR, number_spawn_pos, node)

    # If there exists a hurt timer, destroy it.
    # (Don't trigger timeout event.)
    if hurt_timer != null:
        hurt_timer.destroy_timer()
        hurt_timer = null

    # Won't play hurt animation if it is stunned.
    if animator.get_current_animation() != "Stunned":
        play_animation("Hurt")
        hurt_timer = countdown_timer.new(HURT_ANIM_DURATION, node, "resume_from_damaged")

    # Show health bar.
    if health_system.health > 0:
        health_bar.set_health_bar_and_show(float(health_system.health) / float(health_system.full_health))
    else:
        health_bar.queue_free()

# NOTE that this function should be called by the node.
func resume_from_damaged():
    hurt_timer = null
    play_animation(still_anim_name)

func stunned(duration):
    # Cancel hurt timer so that it won't recover to Still animation.
    if hurt_timer != null:
        hurt_timer.destroy_timer()
        hurt_timer = null

    # Stunned text (number indicator).
    var stunned_text = number_indicator.instance()
    stunned_text.initialize(-1, STUNNED_TEXT_COLOR, number_spawn_pos, node)
    
    # If the node is currently stunned, Destroy the previous effect and apply the new one.
    if stun_timer != null:
        stun_timer.destroy_timer()
        stun_timer = null
    
    play_animation("Stunned")
    stun_timer = countdown_timer.new(duration, node, "resume_from_stunned")

# NOTE that this function should be called by the node.
func resume_from_stunned():
    stun_timer = null
    play_animation(still_anim_name)