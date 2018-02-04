extends KinematicBody2D

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

onready var spawn_pos = get_node("Spawn Pos")
onready var gravity_movement = preload("res://Scripts/Movements/GravityMovement.gd").new(self, GRAVITY)
onready var animator = get_node("Animation/AnimationPlayer")

func _ready():
	animator.play("Still")

	if additional_spawn_1 != "Null":
		scenes.push_back(load(additional_spawn_1))
	
	if additional_spawn_2 != "Null":
		scenes.push_back(load(additional_spawn_2))

	if additional_spawn_3 != "Null":
		scenes.push_back(load(additional_spawn_3))

	set_process(true)

func _process(delta):
	move_to(gravity_movement.movement(get_global_pos(), delta))

func damaged(val):
	open_box()

func knocked_back(vel_x, vel_y, x_fade_rate):
	pass

func stunned(duration):
	pass

func open_box():
	animator.play("Explode")

	var spawned_scene = scenes[randi() % scenes.size()].instance()
	get_node("..").add_child(spawned_scene)
	spawned_scene.set_global_pos(spawn_pos.get_global_pos())

	set_process(false)
	timer = preload("res://Scripts/Utils/CountdownTimer.gd").new(EXPLODE_DURATION, self, "queue_free")

func healed(val):
	pass

func slowed(mult, duration):
	pass