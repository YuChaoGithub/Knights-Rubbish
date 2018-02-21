# The Timer instance.
var timer

# The parent node which instanced the Timer node.
var parent

# Being called every tick.
var tick_func_name

var total_ticks
var curr_tick = 0

# The arguments for the tick function.
var args

func _init(tick_immediately, time_between_ticks, total_ticks, target, tick_func_name, args = null):
    self.parent = target
    self.total_ticks = total_ticks
    self.tick_func_name = tick_func_name
    self.args = args

    timer = Timer.new()
    timer.one_shot = false
    timer.wait_time = time_between_ticks
    timer.connect("timeout", self, "perform_tick")
    target.add_child(timer)
    timer.start()

    if tick_immediately:
        perform_tick()

func perform_tick():
    if args == null:
        parent.call(tick_func_name)
    else:
        parent.call(tick_func_name, args)

    curr_tick += 1
    if curr_tick == total_ticks:
        timer.stop()

func destroy_timer():
    timer.stop()
    timer.queue_free()