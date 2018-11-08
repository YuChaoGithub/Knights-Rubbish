extends Node2D

const HERO_FADING_DURATION = 0.5

export(String, FILE) var to_scene_path

var parent_lerper = preload("res://Scenes/Utils/Parent Opacity Lerper.tscn")
var enter_door_audio = preload("res://Scenes/Characters/EnterDoorAudio.tscn")

func hero_enter(hero):
    hero.status.can_move = false

    var a = enter_door_audio.instance()
    $"..".add_child(a)
    a.global_position = self.global_position

    var lerper = parent_lerper.instance()
    lerper.initialize(hero.modulate.a, 0.0, HERO_FADING_DURATION, self, "switch_scene")
    hero.add_child(lerper)

func switch_scene():
    var loading_scene = get_node("/root/LoadingScene")
    loading_scene.pop_curr_scene_from_stack()
    loading_scene.load_scene(to_scene_path)