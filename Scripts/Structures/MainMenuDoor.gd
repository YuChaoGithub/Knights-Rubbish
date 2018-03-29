extends Node2D

const HERO_FADING_DURATION = 0.5
const main_menu_scene_path = "res://Scenes/UI/Menu.tscn"

var parent_lerper = preload("res://Scenes/Utils/Parent Opacity Lerper.tscn")

func hero_enter(hero):
    hero.status.can_move = false

    var lerper = parent_lerper.instance()
    lerper.initialize(hero.modulate.a, 0.0, HERO_FADING_DURATION, self, "switch_scene")
    hero.add_child(lerper)

func switch_scene():
    get_node("/root/LoadingScene").goto_scene(main_menu_scene_path)