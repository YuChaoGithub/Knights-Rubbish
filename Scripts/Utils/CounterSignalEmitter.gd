extends Node2D

export(int) var count_to_emit = 10

signal count_reached

var curr_count = 0

func increment_count():
    curr_count += 1

    if curr_count == count_to_emit:
        emit_signal("count_reached")