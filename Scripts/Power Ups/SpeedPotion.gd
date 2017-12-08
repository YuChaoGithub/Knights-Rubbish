extends Node2D

const SPEED_MODIFIER = 2.0
const DURATION = 5.0

var movement_pattern

# The affected character
var character_node

var recover_timer

func on_area_entered(area):
	# A character enters.
	if area.is_in_group("player_collider"):
		area.get_node("..").speed_changed(SPEED_MODIFIER, DURATION)
		queue_free()