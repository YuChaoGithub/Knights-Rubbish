extends Node2D

var opened = false

onready var collision_area = $Collision/CollisionArea

func _ready():
	collision_area.add_to_group("enemy")

func break_open():
	opened = true
	collision_area.remove_from_group("enemy")
	$Door/AnimationPlayer.play("Explode")

func hero_enter(hero):
	if opened:
		opened = false
		print("Entered")

func damaged(val):
	break_open()

func stunned(duration):
	pass

func slowed(multplier, duration):
	pass

func knocked_back(vel_x, vel_y, fade_rate):
	pass

func healed(val):
	pass