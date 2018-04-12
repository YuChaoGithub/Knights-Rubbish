extends Position2D

var heroes = []

var dead_hero_count = 0

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
	var hero_indices = get_node("/root/PlayerSettings").heroes_chosen
	
	var player_index = 0
	for hero_index in hero_indices:
		var hero = hero_scenes[hero_index].instance()
		$"..".call_deferred("add_child", hero)
		hero.global_position = global_position

		var action_prefix = "p" + str(int(player_index + 1))
		hero.action_strings = {
			up = action_prefix + "_up",
			down = action_prefix + "_down",
			left = action_prefix + "_left",
			right = action_prefix + "_right",
			attack = action_prefix + "_attack",
			skill = action_prefix + "_skill",
			jump = action_prefix + "_jump",
			ult = action_prefix + "_ult"
		}

		hero.player_index = player_index
		heroes.push_back(hero)
		player_index += 1

func _process(delta):
	following_camera.check_camera_update(get_min_max_pos())

# Returns an array of [Vector2(min_x, min_y), Vector2(max_x, max_y)]
func get_min_max_pos():
	var min_vec = Vector2(1, 1) * 10000000000
	var max_vec = Vector2(1, 1) * -10000000000

	for hero in heroes:
		min_vec.x = min(min_vec.x, hero.global_position.x)
		max_vec.x = max(max_vec.x, hero.global_position.x)
		min_vec.y = min(min_vec.y, hero.global_position.y)
		max_vec.y = max(max_vec.y, hero.global_position.y)

	return [min_vec, max_vec]

# Returns true if a hero is in range of a position.
func in_range_of(pos, range_x, range_y):
	for hero in heroes:
		if abs(hero.global_position.x - pos.x) <= range_x && abs(hero.global_position.y - pos.y) <= range_y:
			return true
	
	return false

func hero_dead():
	dead_hero_count += 1

	if dead_hero_count == heroes.size():
		var ui = game_over_scene.instance()
		add_child(ui)