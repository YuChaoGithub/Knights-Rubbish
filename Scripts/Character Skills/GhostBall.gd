extends Node2D

const FADE_IN_DURATION = 0.5
const FADE_OUT_DURATION = 0.3
const INIT_TRAVEL_SPEED = 200
const TRAVEL_SPEED = 500
const EFFECT_RANGE = 50
const DAMAGE = 4

var target
var faded_in = false

onready var sprite = $Ball
onready var fade_in_tween = $FadeInTween
onready var fade_out_tween = $FadeOutTween
onready var swirl_particles = $SwirlParticles
onready var explode_particles = $ExplodeParticles

func initialize(target):
    self.target = target

func _ready():
    fade_in_tween.interpolate_method(self, "fade", 0.0, 1.0, FADE_IN_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
    fade_out_tween.interpolate_method(self, "fade", 1.0, 0.0, FADE_OUT_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
    fade_in_tween.connect("tween_completed", self, "fade_in_completed")
    fade_out_tween.connect("tween_completed", self, "fade_out_completed")
    fade_in_tween.start()

func fade(progress):
    sprite.modulate.a = progress

func fade_in_completed(object, key):
    faded_in = true

func _process(delta):
    var dir = (target.global_position - global_position).normalized()
    
    global_position += dir * delta * (TRAVEL_SPEED if faded_in else INIT_TRAVEL_SPEED)

    if faded_in && target.global_position.distance_squared_to(global_position) <= EFFECT_RANGE * EFFECT_RANGE:
        set_process(false)
        explode()

func explode():
    target.damaged(DAMAGE, false)

    swirl_particles.emitting = false
    explode_particles.emitting = true
    fade_out_tween.start()

func fade_out_completed(object, key):
    queue_free()