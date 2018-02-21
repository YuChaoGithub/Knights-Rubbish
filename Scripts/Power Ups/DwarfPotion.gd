extends Area2D

const SIZE_MODIFIER = 0.5
const DAMAGE_MODIFIER = 0.75
const DEFENSE_MODIFIER = 1.2
const SELF_KNOCK_BACK_MODIFIER = 1.5
const ENEMY_KNOCK_BACK_MODIFIER = 0.5
const DURATION = 15.0

func on_area_entered(area):
	# A character enters.
	if area.is_in_group("hero"):
		var multipliers = {
			size = SIZE_MODIFIER,
			damage = DAMAGE_MODIFIER,
			defense = DEFENSE_MODIFIER,
			self_knock_back = SELF_KNOCK_BACK_MODIFIER,
			enemy_knock_back = ENEMY_KNOCK_BACK_MODIFIER
		}
		area.get_node("..").dwarfed_or_gianted(multipliers, DURATION)
		
		$"..".queue_free()