extends Node2D

const MOVEMENT_SPEED = 1500
const OFFSET = 50

var target

func initialize(target):
	self.target = target
	set_process(true)

func _process(delta):
	var dir = (target.get_global_pos() - get_global_pos()).normalized()
	translate(dir * MOVEMENT_SPEED * delta)

	if get_global_pos().distance_squared_to(target.get_global_pos()) <= OFFSET * OFFSET:
		target.gain_ult()

		queue_free()