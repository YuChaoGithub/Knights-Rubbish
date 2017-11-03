extends Node2D

onready var bar = get_node("Bar/Bar")

func set_health_bar(percentage):
    bar.set_scale(Vector2(percentage, 1))