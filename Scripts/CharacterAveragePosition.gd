extends Position2D

# An array of characters. Characters will register theirselves to this array.
# This is used so that other nodes (e.g. enemies) can get the respective positions of different characters.
var characters = []

# The total numbers of characters.
var character_count = 0

onready var following_camera = get_node("../Following Camera")

# Add a new character position to track. Also updates the following camera.
func add_character(pos):
	var total_pos = character_count * get_global_pos() + pos
	character_count += 1

	set_global_pos(total_pos / character_count)
	update_camera()

# Delete a tracked character. Also updates the following camera.
func delete_character(pos):
	var total_pos = character_count * get_global_pos() - pos
	character_count -= 1

	set_global_pos(total_pos / character_count)
	update_camera()

# Update the position according to individule character position updates.
# Also updates the following camera.
func update_pos(original_pos, new_pos):
	set_global_pos((get_global_pos() * character_count - original_pos + new_pos) / character_count)

	update_camera()

# Update the following camera according to its position.
func update_camera():
	following_camera.check_camera_update(get_global_pos())