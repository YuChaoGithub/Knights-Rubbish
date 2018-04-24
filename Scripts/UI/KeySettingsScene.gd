extends CanvasLayer

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