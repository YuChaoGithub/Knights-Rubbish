extends KinematicBody2D

const SPEED_X = 1500

const ROTATION_SPEED = 4 * PI

const SCALE_INIT = 0.2
const SCALE_FINAL = 0.8
const SCALE_DURATION = 0.6

const INIT_DAMAGE_MIN = 80
const INIT_DAMAGE_MAX = 90
const DAMAGE_MIN = 20
const DAMAGE_REDUCE_RATE = 0.7

const KNOCK_BACK_VEL_X = 300
const KNOCK_BACK_VEL_Y = 50
const KNOCK_BACK_FADE_RATE = 600

const LIFE_TIME = 6.0
const VANISH_TIME = 0.15

var timestamp = 0.0

var side
var attack_modifier
var knock_back_modifier
var size

var fading_out = false

var damage

var rng = preload("res://Scripts/Utils/RandomNumberGenerator.gd")

onready var movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(side * SPEED_X, 0)
onready var scale_tween = $ScaleTween
onready var fade_out_tween = $FadeTween
onready var sprite = $Sprite

func initialize(side, attack_modifier, knock_back_modifier, size):
	self.side = side
	self.attack_modifier = attack_modifier
	self.knock_back_modifier = knock_back_modifier
	self.size = size

func _ready():
	scale = scale * SCALE_INIT * size
	
	damage = int(rng.randi_range(INIT_DAMAGE_MIN, INIT_DAMAGE_MAX) * attack_modifier)

	scale_tween.interpolate_method(self, "scale_tween_step", SCALE_INIT, SCALE_FINAL, SCALE_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
	scale_tween.start()

	fade_out_tween.connect("tween_completed", self, "fade_out_completed")

func scale_tween_step(progress):
	scale = Vector2(1, 1) * progress * size

func _process(delta):
	var collision = move_and_collide(movement_pattern.movement(delta))

	if collision != null:
		movement_pattern.dx = 0
		fade_out()

	sprite.rotation += delta * ROTATION_SPEED * side

	timestamp += delta
	if timestamp >= LIFE_TIME:
		queue_free()

func fade_out():
	fading_out = true
	fade_out_tween.interpolate_method(self, "fade_out_step", 1.0, 0.0, VANISH_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN)
	fade_out_tween.start()

func fade_out_step(progess):
	sprite.modulate.a = progess

func fade_out_completed(object, key):
	queue_free()
	
func on_enemy_hit(area):
	if !fading_out && area.is_in_group("enemy"):
		var enemy = area.get_node("../..")
		enemy.damaged(damage)
		enemy.knocked_back(side * KNOCK_BACK_VEL_X * knock_back_modifier, -KNOCK_BACK_VEL_Y * knock_back_modifier, KNOCK_BACK_FADE_RATE * knock_back_modifier)

		damage = max(damage * DAMAGE_REDUCE_RATE, DAMAGE_MIN * attack_modifier)