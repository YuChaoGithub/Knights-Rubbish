extends Node2D

var draw_list = []

func _process(delta):
    update()

func _draw():
    for line in draw_list:
        draw_line(line.from_pos, line.to_pos, line.color, line.width)

func add_line(line):
    draw_list.push_back(line)

func clear_all():
    draw_list.clear()