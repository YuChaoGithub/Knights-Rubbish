extends Area2D

const DEFENSE_MODIFIER = 0.5
const DURATION = 30.0

func on_area_entered(area):
	# A character enters.
	if area.is_in_group("hero"):
		area.get_node("..").defense_boosted(DEFENSE_MODIFIER, DURATION)

		$"..".queue_free()