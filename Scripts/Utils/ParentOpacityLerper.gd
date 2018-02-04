extends Node2D

const CAP = 0.95

var curr_alpha
var end_alpha
var smooth

func initialize(curr_alpha, end_alpha, duration):
	self.curr_alpha = curr_alpha
	self.end_alpha = end_alpha
	self.smooth = 1.0 / duration

	set_process(true)

func _process(delta):
	curr_alpha = lerp(curr_alpha, end_alpha, smooth * delta)
	get_node("..").set_opacity(curr_alpha)

	if curr_alpha > CAP:
		get_node("..").set_opacity(1.0)

		queue_free()