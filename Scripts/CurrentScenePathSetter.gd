extends Node2D

export(String, FILE) var scene_path

func _ready():
	get_node("/root/LoadingScene").curr_scene_path = scene_path