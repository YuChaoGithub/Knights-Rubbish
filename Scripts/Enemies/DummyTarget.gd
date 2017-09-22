extends Node2D

func damaged(value):
    print("Damaged: ", value)

func damaged_over_time(value_per_sec, duration):
    pass

func stunned(duration):
    print("Stunned for ", duration, " seconds.")