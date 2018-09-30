extends Node2D

# Flaggomine AI:
# 1. Wait until characters enter the trigger area.
# 2. Explode.

const DAMAGE = 50
const KNOCK_BACK_VEL_X = 500
const KNOCK_BACK_VEL_Y = 500
const KNOCK_BACK_FADE_RATE = 1000

const BLINKING_DURATION = 1.0
const EXPLODE_DURATION = 0.5

var cd_timer = preload("res://Scripts/Utils/CountdownTimer.gd")

var timer = null
var triggered = false

onready var animator = $"Animation/AnimationPlayer"

func _ready():
	animator.play("Invisible")

func on_triggered(area):
	if !triggered && area.is_in_group("hero"):
		animator.play("Blinking")
		triggered = true
		timer = cd_timer.new(BLINKING_DURATION, self, "explode")

func on_attack_hit(area):
	if area.is_in_group("hero"):
		var character = area.get_node("..")
		character.damaged(DAMAGE, false)
		character.knocked_back(sign(character.global_position.x - global_position.x) * KNOCK_BACK_VEL_X, -KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)

func explode():
	animator.play("Explode")
	timer = cd_timer.new(EXPLODE_DURATION, self, "queue_free")