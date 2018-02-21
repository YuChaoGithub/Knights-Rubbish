extends Area2D

const DAMAGE_MODIFIER = 2.0
const DURATION = 20.0

func on_area_entered(area):
	# A character enters.
	if area.is_in_group("hero"):
		area.get_node("..").damage_boosted(DAMAGE_MODIFIER, DURATION)
		$"..".queue_free()