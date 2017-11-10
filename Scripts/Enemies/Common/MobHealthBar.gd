extends Node2D

const SHOW_DURATION = 3

var timer = null

onready var bar = get_node("Bar/Bar")
onready var animator = get_node("AnimationPlayer")

func _ready():
    animator.play("Hide")

func set_health_bar_and_show(percentage):
    set_health_bar(percentage)
    fade_in_or_show()

func set_health_bar(percentage):
    bar.set_scale(Vector2(percentage, 1))

func fade_in_or_show():
    if timer == null:
        animator.play("Fade In")
    else:
        timer.destroy_timer()
    
    timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(SHOW_DURATION, self, "fade_out")

func fade_out():
    animator.play("Fade Out")
    timer = null