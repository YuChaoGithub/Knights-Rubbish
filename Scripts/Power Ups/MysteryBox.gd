extends KinematicBody2D

export(int) var activate_range_x = 2000
export(int) var activate_range_y = 2000
export(String, FILE) var additional_spawn_1 = "Null"
export(String, FILE) var additional_spawn_2 = "Null"
export(String, FILE) var additional_spawn_3 = "Null"

const GRAVITY = 600
const EXPLODE_DURATION = 0.3

var scenes = [
	preload("res://Scenes/Power Ups/Dwarf Potion.tscn"),
	preload("res://Scenes/Power Ups/Giant Potion.tscn"),
	preload("res://Scenes/Power Ups/Healing Potion.tscn"),
	preload("res://Scenes/Power Ups/Attack Potion.tscn"),
	preload("res://Scenes/Power Ups/Speed Potion.tscn")
]

var timer
var activated = false

onready var enemy_layer = ProjectSettings.get_setting("layer_names/2d_physics/enemy")
onready var damage_area = $"Animation/Damage Area"
onready var hero_manager = $"../../HeroManager"
onready var spawn_pos = $"Spawn Pos"
onready var gravity_movement = preload("res://Scripts/Movements/GravityMovement.gd").new(self, GRAVITY)
onready var animator = $"Animation/AnimationPlayer"

func _ready():
	animator.play("Still")

	if additional_spawn_1 != "Null":
		scenes.push_back(load(additional_spawn_1))
	
	if additional_spawn_2 != "Null":
		scenes.push_back(load(additional_spawn_2))

	if additional_spawn_3 != "Null":
		scenes.push_back(load(additional_spawn_3))

func _process(delta):
	if activated:
		gravity_movement.move(delta)
	elif hero_manager.in_range_of(global_position, activate_range_x, activate_range_y):
		activated = true
		damage_area.set_collision_layer_bit(enemy_layer, true)

func damaged(val):
	open_box()

func knocked_back(vel_x, vel_y, x_fade_rate):
	pass

func stunned(duration):
	pass

func open_box():
	animator.play("Explode")

	var spawned_scene = scenes[randi() % scenes.size()].instance()
	$"..".add_child(spawned_scene)
	spawned_scene.global_position = spawn_pos.global_position

	set_process(false)
	timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(EXPLODE_DURATION, self, "queue_free")

func healed(val):
	pass

func slowed(mult, duration):
	pass