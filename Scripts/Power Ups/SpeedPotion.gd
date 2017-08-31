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
		character_node = area.get_node("..")
		character_node.movement_speed_modifier *= SPEED_MODIFIER
		
		# Remove the trigger area to avoid multiple effects.
		get_node("Trigger Area").queue_free()
		
		# Configure timer and start it. Recover the modifiers after the timer ends.
		recover_timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(DURATION, self, "recover")

# Restore the effects.
func recover():
	character_node.movement_speed_modifier /= SPEED_MODIFIER
	
	# Remove the shrink potion scene entirely.
	queue_free()