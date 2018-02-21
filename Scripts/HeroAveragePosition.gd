extends Position2D

# An array of characters. Characters will register theirselves to this array.
# This is used so that other nodes (e.g. enemies) can get the respective positions of different characters.
var characters = []

# The total numbers of characters.
var character_count = 0

onready var following_camera = $"../Following Camera"

# Add a new character position to track. Also updates the following camera.
func add_character(pos):
	var total_pos = character_count * global_position + pos
	character_count += 1

	global_position = total_pos / character_count
	update_camera()

# Delete a tracked character. Also updates the following camera.
func delete_character(pos):
	var total_pos = character_count * global_position - pos
	character_count -= 1

	global_position = total_pos / character_count
	update_camera()

# Update the position according to individule character position updates.
# Also updates the following camera.
func update_pos(original_pos, new_pos):
	global_position = (global_position * character_count - original_pos + new_pos) / character_count

	update_camera()

# Update the following camera according to its position.
func update_camera():
	var max_y = -10000000000.0
	for character in characters:
		max_y = max(max_y, character.global_position.y)

	following_camera.check_camera_update(global_position.x, max_y)

# Returns true if a character is in range of a position.
func in_range_of(pos, range_x, range_y):
	for character in characters:
		if abs(character.global_position.x - pos.x) <= range_x && abs(character.global_position.y - pos.y) <= range_y:
			return true
	
	return false