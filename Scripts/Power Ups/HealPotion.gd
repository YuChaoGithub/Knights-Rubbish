extends Area2D

export(int) var heal_amount = 100

func on_area_entered(area):
	# A character enters.
	if area.is_in_group("hero"):
		var character = area.get_node("..")
		
		# Won't consume the potion if the character is full health.
		if !character.health_system.is_full_health():
			character.healed(heal_amount)
		
			$"..".queue_free()