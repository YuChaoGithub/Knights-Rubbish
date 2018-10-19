extends KinematicBody2D

const GRAVITY = 600

const DAMAGE = 77
const KNOCK_BACK_VEL_X = 1000
const KNOCK_BACK_VEL_Y = 1000
const KNOCK_BACK_FADE_RATE = 2500
const STUN_DURATION = 0.75

const BLINKING_DURATION = 2.5
const EXPLODE_DURATION = 0.3

var cd_timer = preload("res://Scripts/Utils/CountdownTimer.gd")

var timer = null

onready var animator = $AnimationPlayer
onready var gravity_movement = preload("res://Scripts/Movements/GravityMovement.gd").new(self, GRAVITY)

func _ready():
	animator.play("Still")

func _process(delta):
	gravity_movement.move(delta)

	if gravity_movement.is_landed:
		set_process(false)
		animator.play("Blinking")
		timer = cd_timer.new(BLINKING_DURATION, self, "explode")

func explode():
	animator.play("Explode")
	timer = cd_timer.new(EXPLODE_DURATION, self, "queue_free")

func on_attack_hit(area):
	if area.is_in_group("hero"):
		var character = area.get_node("..")
		character.stunned(STUN_DURATION)
		character.damaged(DAMAGE, false)
		character.knocked_back(sign(character.global_position.x - global_position.x) * KNOCK_BACK_VEL_X, -KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)