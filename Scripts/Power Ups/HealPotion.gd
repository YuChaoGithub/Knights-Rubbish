extends Area2D

export(int) var heal_amount = 100

var small_sprite = preload("res://Graphics/Characters/Common/Power Up/Heal Potion.png")

func on_area_entered(area):
	# A character enters.
	if area.is_in_group("hero"):
		var hero = area.get_node("..")
		if !hero.health_system.is_full_health() && hero.status.can_move && !hero.status.fallen_off && !hero.status.dead:
			character.drink_potion(small_sprite, "healed", heal_amount)
		
			$"..".queue_free()