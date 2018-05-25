extends Node2D

export(int) var total_count = 5

onready var label = $Number
onready var animator = $AnimationPlayer

onready var curr_count = total_count

func _ready():
    label.text = str(total_count)

func tick():
    curr_count -= 1
    label.text = str(curr_count)

    if curr_count == 0:
        animator.play("Arrow")