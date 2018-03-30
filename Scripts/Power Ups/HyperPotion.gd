extends Area2D

const DAMAGE_MULTIPLIER = 2.0
const DURATION = 20.0

var small_sprite = preload("res://Graphics/Characters/Common/Power Up/Attack Potion.png")

func on_area_entered(area):
	# A character enters.
	if area.is_in_group("hero"):
		var args = {
			multiplier = DAMAGE_MULTIPLIER,
			duration = DURATION
		}
		area.get_node("..").drink_potion(small_sprite, "attack_boosted", args)
		$"..".queue_free()