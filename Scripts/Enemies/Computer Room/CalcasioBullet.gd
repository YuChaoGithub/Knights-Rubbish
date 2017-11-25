extends Node2D

const KNOCK_BACK_VEL_X = 200
const KNOCK_BACK_VEL_Y = 0
const KNOCK_BACK_FADE_RATE = 400

const SPEED_X = 500
const LIFETIME = 6

# Number sprites.
var number_textures = [
	preload("res://Graphics/Enemies/Computer Room/Calcasio/1.png"),
	preload("res://Graphics/Enemies/Computer Room/Calcasio/2.png"),
	preload("res://Graphics/Enemies/Computer Room/Calcasio/3.png"),
	preload("res://Graphics/Enemies/Computer Room/Calcasio/4.png"),
	preload("res://Graphics/Enemies/Computer Room/Calcasio/5.png"),
	preload("res://Graphics/Enemies/Computer Room/Calcasio/6.png"),
	preload("res://Graphics/Enemies/Computer Room/Calcasio/7.png")
]

var number
var traveling = false
var movement_pattern
var direction
var lifetime_timestamp

func initialize(number, direction):
	self.number = number
	self.direction = direction

	get_node("Sprite").set_texture(number_textures[int(number) - 1])

func start_travel():
	lifetime_timestamp = OS.get_unix_time()
	set_process(true)
	movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(direction * SPEED_X, 0)
	traveling = true

func _process(delta):
	set_global_pos(movement_pattern.movement(get_global_pos(), delta))

	if OS.get_unix_time() - lifetime_timestamp >= LIFETIME:
		queue_free()

func on_attack_hit(area):
	if traveling && area.is_in_group("player_collider"):
		var character = area.get_node("..")
		character.damaged(number)
		character.knocked_back(sign(movement_pattern.dx) * KNOCK_BACK_VEL_X, KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)

		queue_free()