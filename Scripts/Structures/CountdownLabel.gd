extends Label

export(int) var total_count = 5

onready var curr_count = total_count

func _ready():
    text = str(total_count)

func tick():
    curr_count -= 1
    text = str(curr_count)

    if curr_count == 0:
        text = ""