extends Tween

var curr_alpha
var end_alpha
var duration
var target
var completion_func
var args

func initialize(curr_alpha, end_alpha, duration, target = null, completion_func = null, args = null):
	self.curr_alpha = curr_alpha
	self.end_alpha = end_alpha
	self.duration = duration
	self.target = target
	self.completion_func = completion_func
	self.args = args

func _ready():
	connect("tween_completed", self, "lerping_completed")
	interpolate_method(self, "lerping_step", curr_alpha, end_alpha, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	start()

func lerping_step(progress):
	$"..".modulate.a = progress

func lerping_completed(object, key):
	if target != null:
		if args != null:
			target.call(completion_func, args)
		else:
			target.call(completion_func)
		
	queue_free()