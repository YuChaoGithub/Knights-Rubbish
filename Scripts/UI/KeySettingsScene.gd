extends CanvasLayer

var combo_tutorial_scene = preload("res://Scenes/UI/Combo Tutorial.tscn")

onready var mouse_disabler = $MouseDisabler
onready var animator = $AnimationPlayer

var resume_scene = null

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
    var ct_scene = combo_tutorial_scene.instance()
    ct_scene.resume_scene = self
    add_child(ct_scene)
    set_process(false)

func resume_current():
    set_process(true)

func confirm_button_pressed():
    if resume_scene != null:
        resume_scene.resume_current()
        resume_scene = null

    get_node("/root/Initializer").save_key_config()

    # queue_free() will be called in this animation.
    animator.play("Leave")