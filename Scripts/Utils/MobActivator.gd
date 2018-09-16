extends Node2D

func activate():
    for mob in get_children():
        mob.activate()