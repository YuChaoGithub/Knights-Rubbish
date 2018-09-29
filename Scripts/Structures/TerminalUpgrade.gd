extends Node2D

export(String, FILE) var enter_scene_path

const HERO_FADING_DURATION = 1.0

var parent_lerper = preload("res://Scenes/Utils/Parent Opacity Lerper.tscn")

onready var hit_area = $Collision/HitArea
onready var enter_area = $Collision/EnterArea

func _ready():
    hit_area.add_to_group("enemy")

func activate():
    hit_area.remove_from_group("enemy")
    enter_area.add_to_group("door")
    $AnimationPlayer.play("Hit")

func hero_enter(hero):
    hero.status.can_move = false

    var lerper = parent_lerper.instance()
    lerper.initialize(hero.modulate.a, 0.0, HERO_FADING_DURATION, self, "switch_scene")
    hero.add_child(lerper)

func switch_scene():
    var loading_scene = get_node("/root/LoadingScene")
    loading_scene.pop_curr_scene_from_stack()
    loading_scene.load_scene(enter_scene_path)

func damaged(val):
    activate()

func stunned(duration):
    pass

func slowed(multiplier, duration):
    pass

func knocked_back(vel_x, vel_y, fade_rate):
    pass

func healed(val):
    pass