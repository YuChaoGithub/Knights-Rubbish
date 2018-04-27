extends Node2D

const HERO_FADE_DURATION = 0.15
const HERO_FREEZE_DURATION = 0.3

export(NodePath) var destination_node_path

var parent_lerper = preload("res://Scenes/Utils/Parent Opacity Lerper.tscn")

onready var blink_animator = $WhiteCover/AnimationPlayer
onready var destination = get_node(destination_node_path)

func hero_enter(hero):
    hero.set_status("can_move", false, HERO_FREEZE_DURATION)
    
    var lerper = parent_lerper.instance()
    lerper.initialize(hero.modulate.a, 0.0, HERO_FADE_DURATION, hero, "reset_alpha_and_teleport_to_position", destination.global_position)
    hero.add_child(lerper)

    blink_animator.play("Blink")