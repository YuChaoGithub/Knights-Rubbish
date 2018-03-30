extends Position2D

# An array of characters. Characters will register theirselves to this array.
# This is used so that other nodes (e.g. enemies) can get the respective positions of different characters.
var characters = []

# The total numbers of characters.
var character_count = 0

var dead_character_count = 0

var game_over_scene = preload("res://Scenes/UI/Game Over.tscn")

onready var following_camera = $"../FollowingCamera"

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
	following_camera.check_camera_update(get_min_max_pos())

# Returns an array of [Vector2(min_x, min_y), Vector2(max_x, max_y)]
func get_min_max_pos():
	var min_vec = Vector2(1, 1) * 10000000000
	var max_vec = Vector2(1, 1) * -10000000000

	for character in characters:
		min_vec.x = min(min_vec.x, character.global_position.x)
		max_vec.x = max(max_vec.x, character.global_position.x)
		min_vec.y = min(min_vec.y, character.global_position.y)
		max_vec.y = max(max_vec.y, character.global_position.y)

	return [min_vec, max_vec]

# Returns true if a character is in range of a position.
func in_range_of(pos, range_x, range_y):
	for character in characters:
		if abs(character.global_position.x - pos.x) <= range_x && abs(character.global_position.y - pos.y) <= range_y:
			return true
	
	return false

func character_dead():
	dead_character_count += 1

	if dead_character_count == character_count:
		var ui = game_over_scene.instance()
		add_child(ui)