extends Node2D

const SPEED = 600.0

onready var char_icon = $"Sprite/Icon"
onready var drop_pos = $"Drop Pos"
onready var animator = $"AnimationPlayer"

func perform_movement(side, delta):
	var final_pos = Vector2(global_position.x + side * delta * SPEED, global_position.y)
	
	# Camera.
	final_pos = $"..".clamp_pos_within_cam_bounds(final_pos)

	global_position = final_pos

func set_icon_texture(icon_texture):
	char_icon.texture = icon_texture

func get_drop_pos():
	return drop_pos.global_position

func release():
	animator.play("Release")