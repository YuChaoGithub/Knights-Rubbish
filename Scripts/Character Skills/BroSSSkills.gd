extends Node2D


# All brothers' information.
const MOVEMENT_SPEEDS = [400.0, 300.0, 500.0]
const JUMP_TO_HEIGHTS = [0.4, 0.6, 0.8]
const ANIMATORS = ["SugAnimator", "SirAnimator", "BigBrotherAnimator"]
var curr_char = 0

onready var hero = get_node("..")
onready var spawn_node = get_node("../..")

var rng = preload("res://Scripts/Utils/RandomNumberGenerator.gd")

func _ready():
    pass

func _process(delta):
    pass

func basic_attack():
    pass

func basic_skill():
    pass

func horizontal_skill(side):
    pass

func up_skill():
    pass

func down_skill():
    pass

func reset_hero_constants():
    pass

func ult():
    pass

func cancel_all_skills():
    pass