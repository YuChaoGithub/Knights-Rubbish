extends Area2D

const DEFENSE_MULTIPLIER = 0.5
const DURATION = 30.0

var small_sprite = preload("res://Graphics/Characters/Common/Power Up/Defense Potion.png")

func on_area_entered(area):
	# A character enters.
	if area.is_in_group("hero"):
		var hero = area.get_node("..")
		if hero.status.can_move && !hero.status.fallen_off && !hero.status.dead:
			var args = {
				multiplier = DEFENSE_MULTIPLIER,
				duration = DURATION
			}
			hero.drink_potion(small_sprite, "defense_boosted", args)

			$"..".queue_free()