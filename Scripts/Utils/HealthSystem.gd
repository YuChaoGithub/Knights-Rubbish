# Health system for enemies and characters.
var health
var full_health
var parent_node

func _init(parent_node, full_health):
    self.parent_node = parent_node
    self.health = full_health
    self.full_health = full_health

# If the health drops below 0 after the change, calls die() in parent_node.
func change_health_by(val):
    health = clamp(health + val, 0, full_health)

    if health == 0:
        parent_node.call("die")

func is_full_health():
    return health == full_health