extends Node2D

export(String, FILE) var scene_path
export(String, FILE) var quit_to_scene_path

func _ready():
	var loading_scene = get_node("/root/LoadingScene")
	loading_scene.curr_scene_path = scene_path
	loading_scene.quit_to_scene_path = quit_to_scene_path