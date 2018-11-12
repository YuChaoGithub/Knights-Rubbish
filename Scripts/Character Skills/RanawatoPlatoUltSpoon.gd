extends KinematicBody2D

const SPEED = 2500

const DAMAGE = 150

const KNOCK_BACK_VEL_X = 300
const KNOCK_BACK_VEL_Y = 50
const KNOCK_BACK_FADE_RATE = 600

const LIFE_TIME = 6.0

var timestamp = 0.0

var dir
var attack_modifier
var knock_back_modifier
var size

var hit = false

var rng = preload("res://Scripts/Utils/RandomNumberGenerator.gd")
var straight_movement = preload("res://Scripts/Movements/StraightLineMovement.gd")
var movement_pattern

func initialize(attack_modifier, knock_back_modifier, size):
    var rad = rng.randf_range(0.0, 6.28)
    dir = Vector2(cos(rad), sin(rad)).normalized()
    movement_pattern = straight_movement.new(dir.x * SPEED, dir.y * SPEED)
    
    self.attack_modifier = attack_modifier
    self.knock_back_modifier = knock_back_modifier
    self.size = size

func _ready():
    scale = scale * size

func _process(delta):
    var collision = move_and_collide(movement_pattern.movement(delta))

    if collision != null:
        explode()

    timestamp += delta
    if timestamp >= LIFE_TIME:
        queue_free()

func on_enemy_hit(area):
    if !hit && area.is_in_group("enemy"):
        var enemy = area.get_node("../..")
        enemy.knocked_back(sign(enemy.global_position.x - self.global_position.x) * KNOCK_BACK_VEL_X * knock_back_modifier, -KNOCK_BACK_VEL_Y * knock_back_modifier, KNOCK_BACK_FADE_RATE * knock_back_modifier)
        enemy.damaged(int(DAMAGE * attack_modifier))

        explode()

func explode():
    hit = true
    $AnimationPlayer.play("Explode")
    set_process(false)