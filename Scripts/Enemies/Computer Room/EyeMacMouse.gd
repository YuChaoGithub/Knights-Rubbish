extends Node2D

const SPEED = 800

const DAMAGE = 44
const KNOCK_BACK_VEL_X = 300
const KNOCK_BACK_VEL_Y = 300
const KNOCK_BACK_FADE_RATE = 600
const CONFUSION_DURATION = 2.5

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

onready var sprite = $Sprite

func _ready():
	texture_index = randi() % white_textures.size()
	sprite.set_texture(white_textures[texture_index])

func initialize(direction):
	movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(direction.x * SPEED, direction.y * SPEED)
	rotation = atan2(direction.y, direction.x)

func _process(delta):
	global_position += movement_pattern.movement(delta)

	timestamp += delta
	if timestamp > LIFETIME:
		queue_free()

func transform_triggered(area):
	if area.is_in_group("Mouse Transform"):
		sprite.set_texture(transformed_textures[texture_index])

func on_attack_hit(area):
	if area.is_in_group("hero"):
		var character = area.get_node("..")
		character.confused(CONFUSION_DURATION)
		character.damaged(DAMAGE, false)
		character.knocked_back(sign(movement_pattern.dx) * KNOCK_BACK_VEL_X, -KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)

		# Will be freed in the animation.
		set_process(false)
		$AnimationPlayer.play("Explode")