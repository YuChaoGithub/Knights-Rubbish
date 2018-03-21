extends KinematicBody2D

export(int) var activate_range_x = 2000
export(int) var activate_range_y = 2000

const GRAVITY = 600

var activated = false

onready var hero_layer = ProjectSettings.get_setting("layer_names/2d_physics/hero")
onready var gravity_movement = preload("res://Scripts/Movements/GravityMovement.gd").new(self, GRAVITY)
onready var char_average_pos = $"../../Character Average Position"

func _process(delta):
    if activated:
        gravity_movement.move(delta)
    elif char_average_pos.in_range_of(global_position, activate_range_x, activate_range_y):
        activated = true
        $Particles2D.visible = true
        $"Trigger Area".set_collision_mask_bit(hero_layer, true)
        