extends KinematicBody2D

const GRAVITY = 600

const DAMAGE = 50
const KNOCK_BACK_VEL_X = 500
const KNOCK_BACK_VEL_Y = 500
const KNOCK_BACK_FADE_RATE = 1000

const BLINKING_DURATION = 2.5
const EXPLODE_DURATION = 0.3

var cd_timer = preload("res://Scripts/Utils/CountdownTimer.gd")

var timer = null

onready var animator = get_node("AnimationPlayer")
onready var gravity_movement = preload("res://Scripts/Movements/GravityMovement.gd").new(self, GRAVITY)

func _ready():
	animator.play("Still")
	set_process(true)

func _process(delta):
	move_to(gravity_movement.movement(get_global_pos(), delta))

	if gravity_movement.is_landed():
		set_process(false)
		animator.play("Blinking")
		timer = cd_timer.new(BLINKING_DURATION, self, "explode")

func explode():
	animator.play("Explode")
	timer = cd_timer.new(EXPLODE_DURATION, self, "queue_free")

func on_attack_hit(area):
	if area.is_in_group("player_collider"):
		var character = area.get_node("..")
		character.damaged(DAMAGE)
		character.knocked_back(sign(character.get_global_pos().x - get_global_pos().x) * KNOCK_BACK_VEL_X, -KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)