extends KinematicBody2D

var side
var size
var combo_handler

const SPEED_X = 3000
const GRAVITY = 2500
const SLIP_RATIO = 0.2
const TOTAL_LIFE_TIME = 0.8

var hit = false

var timestamp = 0.0

onready var following_camera = $"../FollowingCamera"
onready var movement_pattern = preload("res://Scripts/Movements/StraightLineMovement.gd").new(side * SPEED_X, 0)
onready var gravity_movement = preload("res://Scripts/Movements/GravityMovement.gd").new(self, GRAVITY)

func initialize(side, size, combo_handler):
    self.side = side
    self.size = size
    self.combo_handler = combo_handler
    
func _ready():
    scale.x *= side
    scale  = scale * size

func _process(delta):
    gravity_movement.move(delta)
    var collision = move_and_collide(movement_pattern.movement(delta))
    
    if gravity_movement.is_landed || collision != null || !following_camera.in_camera_view(self.global_position):
        movement_pattern.dx *= SLIP_RATIO
        gravity_movement.dy = 0
        gravity_movement.gravity = 0

        $AnimationPlayer.play("Fade")
        combo_handler.horizontal_skill_cancelled()

        set_process(false)

    timestamp += delta
    if timestamp >= TOTAL_LIFE_TIME:
        combo_handler.horizontal_skill_cancelled()
        queue_free()

func on_enemy_hit(area):
    if !hit && area.is_in_group("enemy"):
        hit = true
        combo_handler.horizontal_skill_hit(area.get_node("../.."))
        queue_free()