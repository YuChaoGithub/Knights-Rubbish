extends Node2D

const HEALTH_HEALING_PORTION = 0.3

var movement_pattern

# The affected character
var character_node

var recover_timer

func on_area_entered(area):
	# A character enters.
	if area.is_in_group("player_collider"):
		character_node = area.get_node("..")
		character_node.health += HEALTH_HEALING_PORTION * character_node.player_constants.full_health
		
		# Remove the scene.
		queue_free()