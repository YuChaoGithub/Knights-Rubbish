extends KinematicBody2D

const SPEED_X = 2000

const ROTATION_SPEED = 6 * PI

const SCALE_INIT = 0.2
const SCALE_FINAL = 1.0
const SCALE_DURATION = 0.3

const DAMAGE = 100

const KNOCK_BACK_VEL_X = 300
const KNOCK_BACK_VEL_Y = 50
const KNOCK_BACK_FADE_RATE = 400

const LIFE_TIME = 6.0
const VANISH_TIME = 0.25

var timestamp = 0.0

var side
var attack_modifier
var knock_back_modifier
var size

var fading_out = false

var explosion_particles = preload("res://Scenes/Particles/Ult Explosion Particles.tscn")

onready var movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(side * SPEED_X, 0)
onready var scale_tween = $ScaleTween
onready var fade_out_tween = $FadeTween
onready var sprite = $Sprite
onready var float_particles = $FloatParticles

func initialize(side, attack_modifier, knock_back_modifier, size):
    self.side = side
    self.attack_modifier = attack_modifier
    self.knock_back_modifier = knock_back_modifier
    self.size = size

func _ready():
    scale = scale * SCALE_INIT * size

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
    float_particles.emitting = false

    var explosion = explosion_particles.instance()
    get_node("..").add_child(explosion)
    explosion.global_position = global_position
    explosion.emitting = true

    fading_out = true
    fade_out_tween.interpolate_method(self, "fade_out_step", 1.0, 0.0, VANISH_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN)
    fade_out_tween.start()

func fade_out_step(progress):
    sprite.modulate.a = progress

func fade_out_completed(object, key):
    queue_free()

func on_enemy_hit(area):
    if !fading_out && area.is_in_group("enemy"):
        var enemy = area.get_node("../..")
        enemy.damaged(int(DAMAGE * attack_modifier))
        enemy.knocked_back(side * KNOCK_BACK_VEL_X * knock_back_modifier, -KNOCK_BACK_VEL_Y * knock_back_modifier, KNOCK_BACK_FADE_RATE * knock_back_modifier)

        fade_out()