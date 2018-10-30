extends KinematicBody2D

const SPEED_X = 1000
const DAMAGE_MIN = 50
const DAMAGE_MAX = 60
const KNOCK_BACK_VEL_X = 200
const KNOCK_BACK_VEL_Y = 50
const KNOCK_BACK_FADE_RATE = 500

const LIFETIME = 6.0

var timestamp = 0.0

var side
var attack_modifier
var knock_back_modifier
var size
var sequence

var textures = [
    preload("res://Graphics/Characters/Othox Codox/Letters/b.png"),
    preload("res://Graphics/Characters/Othox Codox/Letters/u.png"),
    preload("res://Graphics/Characters/Othox Codox/Letters/l.png"),
    preload("res://Graphics/Characters/Othox Codox/Letters/e.png"),
    preload("res://Graphics/Characters/Othox Codox/Letters/t.png"),
]

var rng = preload("res://Scripts/Utils/RandomNumberGenerator.gd")
onready var movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(side * SPEED_X, 0)

func initialize(side, attack_modifier, knock_back_modifier, size, sequence):
    self.side = side
    self.attack_modifier = attack_modifier
    self.knock_back_modifier = knock_back_modifier
    self.size = size
    self.sequence = sequence

func _ready():
    scale = scale * size
    $Sprite.texture = textures[sequence]

func _process(delta):
    var collision = move_and_collide(movement_pattern.movement(delta))

    if collision != null:
        explode()

    timestamp += delta
    if timestamp >= LIFETIME:
        queue_free()

func on_enemy_hit(area):
    if area.is_in_group("enemy"):
        var enemy = area.get_node("../..")
        enemy.knocked_back(side * KNOCK_BACK_VEL_X * knock_back_modifier, -KNOCK_BACK_VEL_Y * knock_back_modifier, KNOCK_BACK_FADE_RATE * knock_back_modifier)
        enemy.damaged(int(rng.randi_range(DAMAGE_MIN, DAMAGE_MAX) * attack_modifier))

        explode()

func explode():
    set_process(false)
    $AnimationPlayer.play("Explode")