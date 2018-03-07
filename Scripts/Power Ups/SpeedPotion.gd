extends Area2D

const SPEED_MODIFIER = 1.5
const DURATION = 10.0

func on_area_entered(area):
	# A character enters.
	if area.is_in_group("hero"):
		area.get_node("..").speed_changed(SPEED_MODIFIER, DURATION)
		$"..".queue_free()