extends Node2D

const SPEED = 800

const DAMAGE = 30
const KNOCK_BACK_VEL_X = 300
const KNOCK_BACK_VEL_Y = 300
const KNOCK_BACK_FADE_RATE = 600

const LIFETIME = 10.0

var timestamp = 0.0
var texture_index
var movement_pattern

var white_textures = [
	preload("res://Graphics/Enemies/Computer Room/Eyemac/Fat Mouse Siluette.png"),
	preload("res://Graphics/Enemies/Computer Room/Eyemac/Thin Mouse Siluette.png")
]

var transformed_textures = [
	preload("res://Graphics/Enemies/Computer Room/Eyemac/Fat Mouse.png"),
	preload("res://Graphics/Enemies/Computer Room/Eyemac/Thin Mouse.png")
]

var spark = preload("res://Scenes/Utils/Spark.tscn")

onready var sprite = get_node("Sprite")

func _ready():
	texture_index = randi() % white_textures.size()
	sprite.set_texture(white_textures[texture_index])

func initialize(direction):
	print(direction)
	movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(direction.x * SPEED, direction.y * SPEED)
	
	set_rot(atan2(-direction.y, direction.x))
	
	set_process(true)

func _process(delta):
	set_global_pos(movement_pattern.movement(get_global_pos(), delta))

	timestamp += delta
	if timestamp > LIFETIME:
		queue_free()

func transform_triggered(area):
	if area.is_in_group("Mouse Transform"):
		sprite.set_texture(transformed_textures[texture_index])

func on_attack_hit(area):
	if area.is_in_group("player_collider"):
		var character = area.get_node("..")
		character.damaged(DAMAGE)
		character.knocked_back(sign(movement_pattern.dx) * KNOCK_BACK_VEL_X, -KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)

		var new_spark = spark.instance()
		get_node("..").add_child(new_spark)
		new_spark.set_global_pos(get_global_pos())

		queue_free()