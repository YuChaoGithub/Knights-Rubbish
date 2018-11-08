extends Label

export(int) var total_count = 5

onready var curr_count = total_count

onready var tick_audio = $Tick
onready var arrow_audio = $Arrow

func _ready():
    text = str(total_count)

func tick():
    curr_count -= 1
    text = str(curr_count)

    if curr_count == 0:
        text = ""
        arrow_audio.play()
    else:
        tick_audio.play()