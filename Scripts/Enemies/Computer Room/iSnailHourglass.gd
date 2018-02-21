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
	$AnimationPlayer.play("Turn")

func initialize(dir_x):
	movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(dir_x * SPEED_X, 0)

func _process(delta):
	global_position += movement_pattern.movement(delta)

	timestamp += delta
	if timestamp > LIFETIME:
		queue_free()

func on_attack_hit(area):
	if area.is_in_group("hero"):
		var character = area.get_node("..")
		character.damaged(DAMAGE)
		character.speed_changed(SLOW_RATE, SLOW_DURATION)

		var new_spark = spark.instance()
		$"..".add_child(new_spark)
		new_spark.global_position = global_position

		queue_free()