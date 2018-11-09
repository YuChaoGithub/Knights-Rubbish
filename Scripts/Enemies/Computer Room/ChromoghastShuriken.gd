extends Node2D

const SPEED_X = 1500

const DAMAGE = 30
const KNOCK_BACK_VEL_X = 500
const KNOCK_BACK_VEL_Y = 0
const KNOCK_BACK_FADE_RATE = 1250

const LIFETIME = 8.0

var timestamp = 0.0
var dir
var movement_pattern

var hit = false

func _ready():
	$AnimationPlayer.play("Spinning")
	
func initialize(dir):
	self.dir = dir
	movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(dir * SPEED_X, 0)

func _process(delta):
	global_position += movement_pattern.movement(delta)

	timestamp += delta
	if timestamp > LIFETIME:
		queue_free()

func on_attack_hit(area):
	if !hit && area.is_in_group("hero"):
		hit = true

		var character = area.get_node("..")
		character.damaged(DAMAGE)
		character.knocked_back(dir * KNOCK_BACK_VEL_X, KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)

		# Will be freed by the animation.
		set_process(false)
		$AnimationPlayer.play("Explode")