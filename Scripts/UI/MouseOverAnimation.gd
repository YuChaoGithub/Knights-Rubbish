extends Control

onready var animator = $AnimationPlayer

func _ready():
    $UI.connect("mouse_entered", self, "mouse_enter")
    $UI.connect("mouse_exited", self, "mouse_exit")

func mouse_enter():
    var start_position = 0.0

    if animator.is_playing():
        start_position = animator.current_animation_position

    animator.play("Enter")
    animator.seek(start_position, true)

func mouse_exit():
    if animator.is_playing():
        var start_position = animator.current_animation_position
        animator.play_backwards("Enter")
        animator.seek(start_position, true)
    else:
        animator.play_backwards("Enter")