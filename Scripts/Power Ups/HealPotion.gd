extends Area2D

export(int) var heal_amount = 100

var small_sprite = preload("res://Graphics/Characters/Common/Power Up/Heal Potion.png")

func on_area_entered(area):
	# A character enters.
	if area.is_in_group("hero"):
		var character = area.get_node("..")
		
		# Won't consume the potion if the character is full health.
		if !character.health_system.is_full_health():
			character.drink_potion(small_sprite, "healed", heal_amount)
		
			$"..".queue_free()