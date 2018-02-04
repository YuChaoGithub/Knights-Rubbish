# The timer instance.
var timer

# The parent node which instanced the timer.
var parent

# The function being called when time out.
var time_out_func_name

# The arguments for the time out function.
var args

func _init(duration, target, time_out_method_name, args = null):
	self.parent = target
	self.time_out_func_name = time_out_method_name
	self.args = args
	
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(duration)
	timer.connect("timeout", self, "time_out")
	target.add_child(timer)
	timer.start()
	
func time_out():
	if args == null:
		parent.call(time_out_func_name)
	else:
		parent.call(time_out_func_name, args)

	timer.queue_free()

# Stop the timer and remove it from parent.
func destroy_timer():
	timer.stop()
	timer.queue_free()