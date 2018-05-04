extends Area2D

const SPEED_MULTIPLIER = 1.5
const DURATION = 10.0

var small_sprite = preload("res://Graphics/Characters/Common/Power Up/Speed Potion.png")

func on_area_entered(area):
	if area.is_in_group("hero"):
		var hero = area.get_node("..")
		if hero.status.can_move && !hero.status.fallen_off && !hero.status.dead:
			var args = {
				multiplier = SPEED_MULTIPLIER,
				duration = DURATION
			}
			hero.drink_potion(small_sprite, "speed_changed", args)
			$"..".queue_free()