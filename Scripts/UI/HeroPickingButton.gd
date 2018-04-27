extends Control

const HERO_PICKING_SCENE_PATH = "res://Scenes/UI/Hero Choosing Scene.tscn"

func button_pressed():
    get_node("/root/LoadingScene").load_scene(HERO_PICKING_SCENE_PATH)