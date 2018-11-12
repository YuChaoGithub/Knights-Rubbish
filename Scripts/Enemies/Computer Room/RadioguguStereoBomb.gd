extends KinematicBody2D

const GRAVITY = 600

const DAMAGE_PER_TICK = 12
const TIME_PER_TICK = 1.0
const TOTAL_TICKS = 4
const KNOCK_BACK_VEL_X = 1000
const KNOCK_BACK_FADE_RATE = 2500
const KNOCK_BACK_VEL_Y = 1000

onready var gravity_movement = preload("res://Scripts/Movements/GravityMovement.gd").new(self, GRAVITY)

func _process(delta):
    gravity_movement.move(delta)

func attack_hit(area):
    if area.is_in_group("hero"):
        var character = area.get_node("..")

        var dot = preload("res://Scenes/Utils/Change Health OT.tscn").instance()
        character.add_child(dot)
        dot.initialize(-DAMAGE_PER_TICK, TIME_PER_TICK, TOTAL_TICKS)

        character.show_ignited_particles(TIME_PER_TICK * TOTAL_TICKS)
        character.knocked_back(sign(character.global_position.x - self.global_position.x) * KNOCK_BACK_VEL_X, -KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)