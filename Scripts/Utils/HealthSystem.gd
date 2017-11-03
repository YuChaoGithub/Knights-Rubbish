# Health system for enemies and characters.
var health
var full_health
var parent_node
var dot_timer = null
var hot_timer = null

func _init(parent_node, full_health):
    self.parent_node = parent_node
    self.health = full_health
    self.full_health = full_health

# If the health drops below 0 after the change, calls die() in parent_node.
func change_health_by(val):
    health = clamp(health + val, 0, full_health)

    if health == 0:
        parent_node.call("die")

    # DEBUG
    print(str(parent_node), " Health Now: ", health)

# Calls damaged(val) or healed(val) in the enemy node instead of directly reducing the health.
func change_health_over_time_by(time_per_tick, total_ticks, val_per_tick):
    # Damage over time.
    if val_per_tick < 0:
        # If there is a previous DoT effect, cancel it and applies the new one.
        if dot_timer != null:
            dot_timer.destroy_timer()

        # Starts a multi tick timer.
        dot_timer = preload("res://Scripts/Utils/MultiTickTimer.gd").new(true, time_per_tick, total_ticks, parent_node, "damaged", -val_per_tick)
    else: # Heal over time.
        if hot_timer != null:
            hot_timer.destroy_timer()

        # Starts a multi tick timer.
        hot_timer = preload("res://Scripts/Utils/MultiTickTimer.gd").new(true, time_per_tick, total_ticks, parent_node, "healed", val_per_tick)

