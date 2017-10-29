const CHECK_IN_SECS = 1

# The enemy node to activate
var target_node

var activate_range_squared
var char_average_pos

var timer

func _init(target_node, char_average_pos, activate_range):
    self.target_node = target_node
    self.char_average_pos = char_average_pos
    self.activate_range_squared = activate_range * activate_range
    
    # Initialize the timer.
    timer = Timer.new()
    timer.set_one_shot(false)
    timer.set_wait_time(CHECK_IN_SECS)
    timer.connect("timeout", self, "perform_check")
    target_node.add_child(timer)
    timer.start()

func perform_check():
    # Check distance.
    if target_node.get_global_pos().distance_squared_to(char_average_pos.get_global_pos()) <= activate_range_squared:
        target_node.call("activate")
        timer.stop()
        timer.queue_free()