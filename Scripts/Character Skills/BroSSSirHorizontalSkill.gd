extends KinematicBody2D

const SPEED_X = 2000

const DAMAGE_MIN = 40
const DAMAGE_MAX = 50

const KNOCK_BACK_VEL_X = 600
const KNOCK_BACK_VEL_Y = 50
const KNOCK_BACK_FADE_RATE = 1000

const LIFE_TIME = 6.0

var timestamp = 0.0

var side
var attack_modifier
var knock_back_modifier
var size

var hit = false

var rng = preload("res://Scripts/Utils/RandomNumberGenerator.gd")
onready var movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(side * SPEED_X, 0)

func initialize(side, attack_modifier, knock_back_modifier, size):
    self.side = side
    self.attack_modifier = attack_modifier
    self.knock_back_modifier = knock_back_modifier
    self.size = size

func _ready():
    scale.x = scale.x * side
    scale = scale * size
        
func _process(delta):
    var collision = move_and_collide(movement_pattern.movement(delta))
    
    if collision != null:
        explode()
    
    timestamp += delta
    if timestamp >= LIFE_TIME:
        queue_free()
    
func explode():
    hit = true
    set_process(false)
    $AnimationPlayer.play("Explode")
    
func on_enemy_hit(area):
    if !hit && area.is_in_group("enemy"):
        var enemy = area.get_node("../..")
        enemy.knocked_back(side * KNOCK_BACK_VEL_X * knock_back_modifier, -KNOCK_BACK_VEL_Y * knock_back_modifier, KNOCK_BACK_FADE_RATE * knock_back_modifier)
        enemy.damaged(int(rng.randf_range(DAMAGE_MIN, DAMAGE_MAX) * attack_modifier))
    
        explode()