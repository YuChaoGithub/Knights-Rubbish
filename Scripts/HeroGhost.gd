extends Node2D

const GHOST_BALL_INTERVAL = 4.0

var ghost_ball = preload("res://Scenes/Characters/GhostBall.tscn")
var multi_timer = preload("res://Scripts/Utils/MultiTickTimer.gd")

var ghost_ball_timer

onready var enemy_layer = ProjectSettings.get_setting("layer_names/2d_physics/enemy")

func activate():
    if get_node("/root/PlayerSettings").player_count <= 1:
        return

    $Node2D/Area2D.set_collision_layer_bit(enemy_layer, true)
    $"../Damage Area".remove_from_group("hero")

    ghost_ball_timer = multi_timer.new(false, GHOST_BALL_INTERVAL, 1000000000, self, "fire_ghost_ball")

func deactivate():
    $Node2D/Area2D.set_collision_layer_bit(enemy_layer, false)
    $"../Damage Area".add_to_group("hero")

    ghost_ball_timer.destroy_timer()

func damaged(val):
    $"..".ghost_damaged(val)

func fire_ghost_ball():
    var target
    var heroes = $"../../HeroManager".heroes

    for hero in heroes:
        if !hero.status.dead:
            target = hero
            
            var ball = ghost_ball.instance()
            ball.initialize(target)
            $"../..".add_child(ball)
            ball.global_position = global_position

func stunned(duration):
    pass

func slowed(multiplier, duration):
    pass

func knocked_back(vel_x, vel_y, fade_rate):
    pass

func healed(val):
    pass