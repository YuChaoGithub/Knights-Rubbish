extends Node2D

const TAG = "damage_change"
const DAMAGE_MODIFIER = 2
const DURATION = 5.0

var movement_pattern

# The affected character
var character_node

var recover_timer

func on_area_entered(area):
	# A character enters.
	if area.is_in_group("player_collider"):
		character_node = area.get_node("..")
		character_node.damage_modifier *= DAMAGE_MODIFIER
		
		# Remove the trigger area to avoid multiple effects.
		get_node("Trigger Area").queue_free()
		
		# Configure timer and start it. Recover the modifiers after the timer ends.
		recover_timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(DURATION, self, "recover")
		
		# Register to charcter node to avoid conflicting power ups.
		character_node.register_timer(TAG, recover_timer)

# Restore the effects.
func recover():
	character_node.damage_modifier /= DAMAGE_MODIFIER
	
	# Unregister to character node.
	character_node.unregister_timer(TAG)
	
	# Remove the shrink potion scene entirely.
	queue_free()