extends Position2D

var characters = []

var dead_character_count = 0

var hero_scenes = [
	preload("res://Scenes/Characters/Keshia Erasia/Keshia Erasia.tscn"),
	null,
	null,
	null,
	null,
	null,
	null,
	preload("res://Scenes/Characters/Wendy Vista/Wendy Vista.tscn")
]

var game_over_scene = preload("res://Scenes/UI/Game Over.tscn")

onready var following_camera = $"../FollowingCamera"

func _ready():
	# TODO: Get character list from global singleton.
	var p1 = hero_scenes[0].instance()
	$"..".call_deferred("add_child", p1)
	# $"..".add_child(p1)
	p1.global_position = global_position
	p1.action_strings = {
		up = "p1_up",
		down = "p1_down",
		left = "p1_left",
		right = "p1_right",
		attack = "p1_attack",
		skill = "p1_skill",
		jump = "p1_jump",
		ult = "p1_ult"
	}
	characters.push_back(p1)

	var p2 = hero_scenes[7].instance()
	$"..".call_deferred("add_child", p2)
	# $"..".add_child(p2)
	p2.global_position = global_position
	characters.push_back(p2)
	p2.action_strings = {
		up = "p2_up",
		down = "p2_down",
		left = "p2_left",
		right = "p2_right",
		attack = "p2_attack",
		skill = "p2_skill",
		jump = "p2_jump",
		ult = "p2_ult"
	}

# Also updates the following camera.
func update_pos():
	var pos = Vector2(0, 0)
	for character in characters:
		pos += character.global_position

	pos /= characters.size()

	global_position = pos

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

	if dead_character_count == characters.size():
		var ui = game_over_scene.instance()
		add_child(ui)