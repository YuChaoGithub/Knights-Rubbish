extends Node2D

const TRAVEL_TIME = 0.3
const STAY_TIME = 0.2
const KNOCK_BACK_VEL_X = 400
const KNOCK_BACK_VEL_Y = 200
const KNOCK_BACK_FADE_RATE = 800
const DAMAGE_MIN = 300
const DAMAGE_MAX = 500
const PARTICLE_DURATION = 3

var char_pos
var target_ref
var timestamp
var particle_timer

var rng = preload("res://Scripts/Utils/RandomNumberGenerator.gd")

onready var sprite = get_node("Sprite")
onready var particles = get_node("Particles2D")

func initialize(char_pos, target):
	self.char_pos = char_pos
	self.target_ref = weakref(target)

func _ready():
	timestamp = 0.0
	sprite.set_rot(rng.randf_range(0.0, PI * 2.0))
	set_process(true)

func _process(delta):
	var target = target_ref.get_ref()
	if target != null:
		var x_pos = lerp(get_global_pos().x, target.get_global_pos().x, timestamp / TRAVEL_TIME)
		var y_pos = lerp(get_global_pos().y, target.get_global_pos().y, timestamp / TRAVEL_TIME)

		set_global_pos(Vector2(x_pos, y_pos))

		timestamp += delta
		if timestamp > TRAVEL_TIME + STAY_TIME:
			explode(target)
	else:
		queue_free()

func explode(target):
	set_process(false)

	sprite.hide()
	particles.set_emitting(true)

	target.damaged(rng.randi_range(DAMAGE_MIN, DAMAGE_MAX))
	
	var sign_x = sign(target.get_global_pos().x - char_pos.x)
	var sign_y = sign(target.get_global_pos().y - char_pos.y)
	target.knocked_back(sign_x * KNOCK_BACK_VEL_X, sign_y * KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)

	particle_timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(PARTICLE_DURATION, self, "queue_free")