extends Node2D

export(int) var heal_amount = 100
export(float) var interval = 1.0

var timer = null

onready var animator = $AnimationPlayer

func _ready():
	animator.play("Spawn")

func on_potion_collided(area):
	if area.is_in_group("hero"):
		var character = area.get_node("..")
		
		# Won't consume the potion if the character is full health.
		if !character.health_system.is_full_health():
			area.get_node("..").healed(heal_amount)
		
			$Particles2D.visible = false
			animator.play("None")
			timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(interval, self, "spawn_potion")

func spawn_potion():
	animator.play("Spawn")