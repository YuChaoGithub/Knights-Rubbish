extends Node2D

export(int) var heal_amount = 150
export(float) var interval = 1.0

var timer = null

onready var animator = get_node("AnimationPlayer")

func _ready():
	animator.play("Spawn")

func on_potion_collided(area):
	if area.is_in_group("player_collider"):
		var character = area.get_node("..")
		
		# Won't consume the potion if the character is full health.
		if !character.health_system.is_full_health():
			area.get_node("..").healed(heal_amount)
		
			animator.play("None")
			timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(interval, self, "spawn_potion")

func spawn_potion():
	animator.play("Spawn")