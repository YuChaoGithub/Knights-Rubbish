extends TextureRect

var show = true

onready var animator = $"../AnimationPlayer"

func _ready():
    animator.play("Enter")
    connect("mouse_entered", self, "on_mouse_entered")

func on_mouse_entered():
    if animator.current_animation == "":
        if show:
            animator.play("Hide")
            show = false
        else:
            animator.play("Enter")
            show = true