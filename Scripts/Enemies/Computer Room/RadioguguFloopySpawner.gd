extends KinematicBody2D

# 1. Drop on the ground.
# 2. Play Spawn animation and spawn 2 Floopies.

enum { NONE, DROP, ANIM, SPAWN }

const GRAVITY = 600

const SPAWN_ANIMATION_DURATION = 0.7
const SPAWN_ANIMATION_END_DURATION = 0.2

var floopy = preload("res://Scenes/Enemies/Computer Room/Floopy.tscn")
var cd_timer = preload("res://Scripts/Utils/CountdownTimer.gd")

var status_timer = null
var status = NONE

onready var gravity_movement = preload("res://Scripts/Movements/GravityMovement.gd").new(self, GRAVITY)
onready var left_spawn_pos = $"Spawn Pos Left"
onready var right_spawn_pos = $"Spawn Pos Right"
onready var spawn_node = $".."
onready var animator = $"AnimationPlayer"

func _ready():
	animator.play("Still")
	status = DROP

func _process(delta):
	match status:
		DROP:
			drop(delta)
		ANIM:
			play_spawn_anim()
		SPAWN:
			spawn_floopies()

func change_status(to_status):
	status = to_status
	if status_timer != null:
		status_timer.destroy_timer()
		status_timer = null

func drop(delta):
	gravity_movement.move(delta)

	if gravity_movement.is_landed:
		status = ANIM

func play_spawn_anim():
	animator.play("Spawn")
	status = NONE
	status_timer = cd_timer.new(SPAWN_ANIMATION_DURATION, self, "change_status", SPAWN)

func spawn_floopies():
	status = NONE
	status_timer = cd_timer.new(SPAWN_ANIMATION_END_DURATION, self, "queue_free")

	var left_floopy = floopy.instance()
	var right_floopy = floopy.instance()

	spawn_node.add_child(left_floopy)
	spawn_node.add_child(right_floopy)

	left_floopy.global_position = left_spawn_pos.global_position
	right_floopy.global_position = right_spawn_pos.global_position