extends Area2D

const SPEED_MULTIPLIER = 1.5
const DURATION = 10.0

var small_sprite = preload("res://Graphics/Characters/Common/Power Up/Speed Potion.png")

func on_area_entered(area):
	if area.is_in_group("hero"):
		var args = {
			multiplier = SPEED_MULTIPLIER,
			duration = DURATION
		}
		area.get_node("..").drink_potion(small_sprite, "speed_changed", args)
		$"..".queue_free()