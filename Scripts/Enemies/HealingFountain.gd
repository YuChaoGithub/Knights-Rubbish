extends Node2D

export(int) var heal_amount = 10

func _ready():
    get_node("Animation/AnimationPlayer").play("Charging")

func on_zone_enter(area):
    if area.is_in_group("enemy_collider"):
        area.get_node("../..").healed(heal_amount)
