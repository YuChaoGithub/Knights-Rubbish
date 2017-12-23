extends Node2D

const SPEED_X = 200

const DAMAGE = 50
const SLOW_RATE = 0.25
const SLOW_DURATION = 1.5

const LIFETIME = 15.0

var timestamp = 0.0

var spark = preload("res://Scenes/Utils/Spark.tscn")
var dir_x
var movement_pattern

func _ready():
	get_node("AnimationPlayer").play("Turn")

func initialize(dir_x):
	movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(dir_x * SPEED_X, 0)
	set_process(true)

func _process(delta):
	set_global_pos(movement_pattern.movement(get_global_pos(), delta))

	timestamp += delta
	if timestamp > LIFETIME:
		queue_free()

func on_attack_hit(area):
	if area.is_in_group("player_collider"):
		var character = area.get_node("..")
		character.damaged(DAMAGE)
		character.speed_changed(SLOW_RATE, SLOW_DURATION)

		var new_spark = spark.instance()
		get_node("..").add_child(new_spark)
		new_spark.set_global_pos(get_global_pos())

		queue_free()