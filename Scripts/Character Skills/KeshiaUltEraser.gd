extends Node2D

const TRAVEL_TIME = 0.3
const STAY_TIME = 0.2
const KNOCK_BACK_VEL_X = 400
const KNOCK_BACK_VEL_Y = 200
const KNOCK_BACK_FADE_RATE = 800
const DAMAGE_MIN = 350
const DAMAGE_MAX = 550
const PARTICLE_DURATION = 3

var char_pos
var target_ref
var timestamp
var particle_timer

var rng = preload("res://Scripts/Utils/RandomNumberGenerator.gd")

onready var sprite = $Sprite
onready var particles = $Particles2D

func initialize(char_pos, target):
	self.char_pos = char_pos
	self.target_ref = weakref(target)

func _ready():
	timestamp = 0.0
	sprite.rotation = rng.randf_range(0.0, PI * 2.0)

func _process(delta):
	var target = target_ref.get_ref()
	if target != null:
		var x_pos = lerp(global_position.x, target.global_position.x, timestamp / TRAVEL_TIME)
		var y_pos = lerp(global_position.y, target.global_position.y, timestamp / TRAVEL_TIME)

		global_position = Vector2(x_pos, y_pos)

		timestamp += delta
		if timestamp > TRAVEL_TIME + STAY_TIME:
			explode(target)
	else:
		queue_free()

func explode(target):
	set_process(false)

	$Explode.play()

	sprite.visible = false
	particles.emitting = true

	var damage = rng.randi_range(DAMAGE_MIN, DAMAGE_MAX)
	target.damaged(damage)
	get_node("/root/Steamworks").increment_stat("damage_dealt", damage)
	
	var sign_x = sign(target.global_position.x - char_pos.x)
	var sign_y = sign(target.global_position.y - char_pos.y)
	target.knocked_back(sign_x * KNOCK_BACK_VEL_X, sign_y * KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)

	particle_timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(PARTICLE_DURATION, self, "queue_free")