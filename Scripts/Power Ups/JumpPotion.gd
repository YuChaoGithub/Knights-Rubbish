extends Node2D

const TAG = "jump_potion"
const JUMP_HEIGHT_MODIFIER = 2.0
const DURATION = 5.0

const TRY_RECOVER_AGAIN_TIME = 0.1

var movement_pattern

# The affected character
var character_node

var recover_timer

func on_area_entered(area):
	# A character enters.
	if area.is_in_group("player_collider"):
		character_node = area.get_node("..")
		character_node.jump_height_modifier *= JUMP_HEIGHT_MODIFIER
		
		# Remove the trigger area to avoid multiple effects.
		get_node("Trigger Area").queue_free()
		
		# Configure timer and start it. Recover the modifiers after the timer ends.
		recover_timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(DURATION, self, "recover")
		
		# Register to charcter node to avoid conflicting power ups.
		character_node.register_timer(TAG, recover_timer)

# Restore the effects.
func recover():
	# Recover only if the player is landed.
	if character_node.collision_handler.collided_sides[character_node.collision_handler.BOTTOM]:
		character_node.jump_height_modifier /= JUMP_HEIGHT_MODIFIER
	
		# Unregister to character node.
		character_node.unregister_timer(TAG)
	
		# Remove the shrink potion scene entirely.
		queue_free()
	else:
		# Try recover again later.
		recover_timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(TRY_RECOVER_AGAIN_TIME, self, "recover")