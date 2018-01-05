extends Node2D

var health_changer

func initialize(damage_per_tick, time_per_tick, total_ticks):
	health_changer = preload("res://Scripts/Utils/ChangeHealthOverTime.gd").new(self, "effect_ended", -damage_per_tick, time_per_tick, total_ticks)

func perform_tick(count):
	health_changer.perform_tick(count)

func effect_ended():
	queue_free()