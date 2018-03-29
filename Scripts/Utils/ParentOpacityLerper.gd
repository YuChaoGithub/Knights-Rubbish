extends Tween

var curr_alpha
var end_alpha
var duration
var target
var completion_func

func initialize(curr_alpha, end_alpha, duration, target = null, completion_func = null):
	self.curr_alpha = curr_alpha
	self.end_alpha = end_alpha
	self.duration = duration
	self.target = target
	self.completion_func = completion_func

func _ready():
	connect("tween_completed", self, "lerping_completed")
	interpolate_method(self, "lerping_step", curr_alpha, end_alpha, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	start()

func lerping_step(progress):
	$"..".modulate.a = progress

func lerping_completed(object, key):
	if target != null:
		target.call(completion_func)
		
	queue_free()