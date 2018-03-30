extends Node2D

const HEAL_AMOUNT = 100
const INTERVAL = 1.5

var timer = null

onready var animator = $AnimationPlayer

var small_sprite = preload("res://Graphics/Characters/Common/Power Up/Heal Potion.png")

func _ready():
	animator.play("Spawn")

func on_potion_collided(area):
	if area.is_in_group("hero"):
		var character = area.get_node("..")
		
		# Won't consume the potion if the character is full health.
		if !character.health_system.is_full_health():
			area.get_node("..").drink_potion(small_sprite, "healed", HEAL_AMOUNT)
		
			$Particles2D.visible = false
			animator.play("None")
			timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(INTERVAL, self, "spawn_potion")

func spawn_potion():
	animator.play("Spawn")