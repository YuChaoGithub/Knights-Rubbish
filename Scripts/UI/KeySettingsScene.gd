extends CanvasLayer

var combo_tutorial_scene = preload("res://Scenes/UI/Combo Tutorial.tscn")

onready var mouse_disabler = $MouseDisabler
onready var animator = $AnimationPlayer

# Avoid assigning the same key to different actions.
var used_keys = []

func _ready():
    if get_node("/root/PlayerSettings").player_count == 1:
        $PaperSinglePlayer.visible = true
        $PaperP1.visible = false
        $PaperP2.visible = false

func start_configuring():
    mouse_disabler.visible = true
    animator.play("Configure")

func end_configuring():
    mouse_disabler.visible = false
    animator.play("Still")

func info_button_pressed():
    add_child(combo_tutorial_scene.instance())

func confirm_button_pressed():
    # queue_free() will be called in this animation.
    animator.play("Leave")