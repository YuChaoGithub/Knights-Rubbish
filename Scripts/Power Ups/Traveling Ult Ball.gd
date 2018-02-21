extends Node2D

const MOVEMENT_SPEED = 1500
const OFFSET = 50

var target

func initialize(target):
	self.target = target

func _process(delta):
	var dir = (target.global_position - global_position).normalized()
	translate(dir * MOVEMENT_SPEED * delta)

	if global_position.distance_squared_to(target.global_position) <= OFFSET * OFFSET:
		target.gain_ult()

		queue_free()