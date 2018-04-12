extends Node2D

export(int) var activate_range_x = 2000
export(int) var activate_range_y = 2000

const ACCELERATION_Y = 1200
const SHOOT_DURATION = 1.0
const PAUSE_DURATION = 0.2
const INVISIBLE_DURATION = 8.0
const TO_SCALE = 0.25
const SCALE_SMOOTH = 1.0

var speed_y = 1200
var start_travel = false
var timer
var activated = false

var cd_timer = preload("res://Scripts/Utils/CountdownTimer.gd")
var ball = preload("res://Scenes/Power Ups/Traveling Ult Ball.tscn")

onready var enemy_layer = ProjectSettings.get_setting("layer_names/2d_physics/enemy")
onready var damage_area = $"Damage Area/Damage Area"
onready var spinner = $Spinner
onready var hero_manager = $"../../HeroManager"

func _process(delta):
	if start_travel:
		position.y -= speed_y * delta
		speed_y -= ACCELERATION_Y * delta
		if speed_y < 0:
			speed_y = 0
		scale = Vector2(1.0, 1.0) * lerp(scale.x, TO_SCALE, delta * SCALE_SMOOTH)
	elif !activated && hero_manager.in_range_of(global_position, activate_range_x, activate_range_y):
		damage_area.set_collision_layer_bit(enemy_layer, true)
		$Particles2D.visible = true
		activated = true

func being_hit():
	if start_travel:
		return

	if spinner.hit_and_check_if_complete():
		$"Damage Area".queue_free()
		start_travel = true
		timer = cd_timer.new(SHOOT_DURATION, self, "pause_in_air")

func pause_in_air():
	set_process(false)
	timer = cd_timer.new(PAUSE_DURATION, self, "spawn_ball_to_heroes")

func spawn_ball_to_heroes():
	spinner.shoot = true
	$Particles2D.visible = false

	for hero in hero_manager.heroes:
		if hero.status.dead:
			continue
			
		var new_ball = ball.instance()
		get_node("..").add_child(new_ball)
		new_ball.global_position = global_position
		new_ball.initialize(hero)

	$Ball.visible = false
	timer = cd_timer.new(INVISIBLE_DURATION, self, "queue_free")

func damaged(val):
	being_hit()

func knocked_back(vel_x, vel_y, x_fade_rate):
	pass

func stunned(duration):
	pass

func slowed(mult, duration):
	pass