extends KinematicBody2D

const SPEED_X = 1500

const ROTATION_SPEED = 4 * PI

const SCALE_INIT = 0.2
const SCALE_FINAL = 0.8
const SCALE_DURATION = 0.6

const INIT_DAMAGE_MIN = 90
const INIT_DAMAGE_MAX = 100
const DAMAGE_MIN = 20
const DAMAGE_REDUCE_RATE = 0.7

const KNOCK_BACK_VEL_X = 300
const KNOCK_BACK_VEL_Y = 50
const KNOCK_BACK_FADE_RATE = 600

const LIFE_TIME = 2.0

var timestamp = 0.0

var side
var attack_modifier
var knock_back_modifier
var size

var damage

var particles = preload("res://Scenes/Particles/WendyHorizontalSkillParticles.tscn")
var penetrate_audio = preload("res://Scenes/Characters/Wendy Vista/WendyPenetrateAudio.tscn")

var rng = preload("res://Scripts/Utils/RandomNumberGenerator.gd")

onready var movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(side * SPEED_X, 0)
onready var scale_tween = $ScaleTween
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

func scale_tween_step(progress):
	scale = Vector2(1, 1) * progress * size

func _process(delta):
	var collision = move_and_collide(movement_pattern.movement(delta))

	if collision != null:
		movement_pattern.dx = 0
		explode()

	sprite.rotation += delta * ROTATION_SPEED * side

	timestamp += delta
	if timestamp >= LIFE_TIME:
		queue_free()

func explode():
	emit_particles()
	queue_free()
	
func on_enemy_hit(area):
	if area.is_in_group("enemy"):
		var enemy = area.get_node("../..")
		enemy.knocked_back(side * KNOCK_BACK_VEL_X * knock_back_modifier, -KNOCK_BACK_VEL_Y * knock_back_modifier, KNOCK_BACK_FADE_RATE * knock_back_modifier)
		enemy.damaged(damage)
		
		damage = max(damage * DAMAGE_REDUCE_RATE, DAMAGE_MIN * attack_modifier)

		emit_particles()

func emit_particles():
	var a = penetrate_audio.instance()
	$"..".add_child(a)
	a.global_position = self.global_position

	var p = particles.instance()
	$"..".add_child(p)
	p.global_position = self.global_position