# The timer instance.
var timer

# The parent node which instanced the timer.
var parent

# The function being called when time out.
var time_out_func_name

func _init(duration, target, time_out_method_name):
	self.parent = target
	self.time_out_func_name = time_out_method_name
	
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(duration)
	timer.connect("timeout", self, "time_out")
	target.add_child(timer)
	timer.start()
	
func time_out():
	timer.queue_free()
	parent.call(time_out_func_name)