# The scene structure should be:
# Character / Enemy
# |--(Fire/Poison/etc Particle) [node] --> Object of this class.
#     ^ This node should implement perform_tick(count).

var amount_per_tick
var time_per_tick
var total_ticks

var node
var end_func

var timer

func _init(node, end_func, amount_per_tick, time_per_tick, total_ticks):
    self.node = node
    self.end_func = end_func
    self.amount_per_tick = amount_per_tick
    self.time_per_tick = time_per_tick
    self.total_ticks = total_ticks

    perform_tick(0)

func perform_tick(count):
    if count == total_ticks:
        node.call(end_func)
        return

    if amount_per_tick < 0:
        node.get_node("..").damaged(-amount_per_tick)
    else:
        node.get_node("..").healed(amount_per_tick)
    
    timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(time_per_tick, node, "perform_tick", count + 1)