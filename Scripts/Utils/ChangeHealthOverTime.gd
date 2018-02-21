extends Node2D

var amount_per_tick
var time_per_tick
var total_ticks

var timer

func initialize(amount_per_tick, time_per_tick, total_ticks):
    self.amount_per_tick = amount_per_tick
    self.time_per_tick = time_per_tick
    self.total_ticks = total_ticks

    perform_tick(0)

func perform_tick(count):
    if count == total_ticks:
        queue_free()
        return

    if amount_per_tick < 0:
        $"..".damaged(-amount_per_tick)
    else:
        $"..".healed(amount_per_tick)
    
    timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(time_per_tick, self, "perform_tick", count + 1)