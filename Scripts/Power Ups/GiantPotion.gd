extends Area2D

var small_sprite = preload("res://Graphics/Characters/Common/Power Up/Drink me Potion.png")

func on_area_entered(area):
	if area.is_in_group("hero"):
		var hero = area.get_node("..")
		hero.drink_potion(small_sprite, "dwarfed_or_gianted", 2)
		$"..".queue_free()