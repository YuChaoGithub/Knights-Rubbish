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
var spark = preload("res://Scenes/Utils/Spark.tscn")

func _ready():
	get_node("AnimationPlayer").play("Spinning")
	
func initialize(dir):
	self.dir = dir
	set_process(true)
	movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(dir * SPEED_X, 0)

func _process(delta):
	set_global_pos(movement_pattern.movement(get_global_pos(), delta))

	timestamp += delta
	if timestamp > LIFETIME:
		queue_free()

func on_attack_hit(area):
	if area.is_in_group("player_collider"):
		var character = area.get_node("..")
		character.damaged(DAMAGE)
		character.knocked_back(dir * KNOCK_BACK_VEL_X, KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)

		# Instance spark.
		var new_spark = spark.instance()
		get_node("..").add_child(new_spark)
		new_spark.set_global_pos(get_global_pos())

		queue_free()