extends Node2D

const SPEED_Y = 1500

const DAMAGE_MIN = 3
const DAMAGE_MAX = 6
const LIFE_TIME = 1.0

var attack_modifier
var size
var hit = false

var timestamp = 0.0

var rain_sprites = [
    preload("res://Graphics/Characters/Othox Codox/Letters/bigR.png"),
    preload("res://Graphics/Characters/Othox Codox/Letters/bigA.png"),
    preload("res://Graphics/Characters/Othox Codox/Letters/bigI.png"),
    preload("res://Graphics/Characters/Othox Codox/Letters/bigN.png")
]

var rng = preload("res://Scripts/Utils/RandomNumberGenerator.gd")

onready var movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(0, SPEED_Y)

func initialize(attack_modifier, size):
    self.attack_modifier = attack_modifier
    self.size = size

func _ready():
    scale = scale * size
    $Sprite.rotation_degrees = rng.randf_range(0.0, 360.0)
    $Sprite.texture = rain_sprites[rng.randi_range(0, rain_sprites.size())]

func _process(delta):
    global_position += movement_pattern.movement(delta)

    timestamp += delta
    if timestamp >= LIFE_TIME:
        queue_free()

func on_enemy_hit(area):
    if !hit && area.is_in_group("enemy"):
        var enemy = area.get_node("../..")
        enemy.damaged(int(rng.randi_range(DAMAGE_MIN, DAMAGE_MAX) * attack_modifier))

        hit = true

        set_process(false)
        $AnimationPlayer.play("Explode")