extends Node2D

const SPEED = 600.0

onready var char_icon = get_node("Sprite/Icon")
onready var drop_pos = get_node("Drop Pos")
onready var animator = get_node("AnimationPlayer")

func perform_movement(side, delta):
	var final_pos = Vector2(get_global_pos().x + side * delta * SPEED, get_global_pos().y)
	
	# Camera.
	final_pos = get_node("..").clamp_pos_within_cam_bounds(final_pos)

	set_global_pos(final_pos)

func initialize(icon_texture):
	char_icon.texture = icon_texture

func get_drop_pos():
	return drop_pos.get_global_pos()

func release():
	animator.play("Release")