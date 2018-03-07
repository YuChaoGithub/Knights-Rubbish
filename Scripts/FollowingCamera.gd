tool
extends Node2D

const CAMERA_SMOOTH = 2.0

# The larger the zoom factor is, the more view the camera will cover.
const ZOOM_FACTOR = 2.0

# Drag margins (from 0 to 1).
export(float) var drag_margin_right = 0.5
export(float) var drag_margin_left = 0.3
export(float) var drag_margin_top = 0.5
export(float) var drag_margin_bottom = 0.8

# Max/Min limits of the camera position (+ margin).
export(int, -1000000000, 1000000000) var right_limit = 1000000000
export(int, -1000000000, 1000000000) var left_limit = -1000000000
export(int, -1000000000, 1000000000) var top_limit = -1000000000
export(int, -1000000000, 1000000000) var bottom_limit = 10000000000

var cam_width
var cam_height

# Only move camera when the semaphore is 0.
var cam_lock_semaphore = 0

# For grabbing and dropping the character from the screen edges.
var bottom_grab = preload("res://Scenes/UI/Bottom Grab.tscn")
var top_fist = preload("res://Scenes/UI/Top Fist.tscn")

# The target position for the camera.
onready var target_pos = global_position

# A Vector2 storing the screen size.
onready var screen_size = get_viewport_rect().size

func _draw():
	if Engine.editor_hint:
		for i in [0.1, 0.2, 0.3, 0.4, 0.5]:
			draw_line(Vector2(-cam_width * i, -cam_height * 0.5), Vector2(-cam_width * i, cam_height * 0.5), Color(1.0, 0.0, 0.0), 1)
			draw_line(Vector2(cam_width * i, -cam_height * 0.5), Vector2(cam_width * i, cam_height * 0.5), Color(1.0, 0.0, 0.0), 1)
			draw_line(Vector2(-cam_width * 0.5, -cam_height * i), Vector2(cam_width * 0.5, -cam_height * i), Color(1.0, 0.0, 0.0), 1)
			draw_line(Vector2(-cam_width * 0.5, cam_height * i), Vector2(cam_width * 0.5, cam_height * i), Color(1.0, 0.0, 0.0), 1)

func _ready():
	cam_width = screen_size.x * ZOOM_FACTOR
	cam_height = screen_size.y * ZOOM_FACTOR
	set_process(false)

	if !Engine.editor_hint:
		# Initialize the zooming of the viewport.
		var canvas_transform = get_viewport().canvas_transform
		canvas_transform.x /= ZOOM_FACTOR
		canvas_transform.y /= ZOOM_FACTOR
		get_viewport().canvas_transform = canvas_transform
		
		set_process(true)
	
func _process(delta):
	# Move the camera closer to its target position.
	var new_pos_x = lerp(global_position.x, target_pos.x, delta * CAMERA_SMOOTH)
	var new_pos_y = lerp(global_position.y, target_pos.y, delta * CAMERA_SMOOTH)
	global_position = Vector2(new_pos_x, new_pos_y)
		
	# Actually move the viewport.
	update_viewport()
	
# Detmermine whether or not to update the camera according to the position of the character.
# This function should be called by the player movement script.
func check_camera_update(x_pos, y_pos):
	if cam_lock_semaphore != 0:
		return

	var new_camera_pos = global_position
	# Check if the character reaches the horizontal margins. If so, update the position of the camera.
	if x_pos > global_position.x + cam_width * (drag_margin_right - 0.5):
		# Character reaches the right drag margin.
		new_camera_pos.x = x_pos - cam_width * (drag_margin_right - 0.5)
	elif x_pos < global_position.x + cam_width * (drag_margin_left - 0.5):
		# Character reaches the left drag margin.
		new_camera_pos.x = x_pos + cam_width * (0.5 - drag_margin_left)
	
	# Vertical margin checks.
	if y_pos > global_position.y + cam_height * (drag_margin_bottom - 0.5):
		# Character reaches the bottom drag margin.
		new_camera_pos.y = y_pos - cam_height * (drag_margin_bottom - 0.5)
	elif y_pos < global_position.y + cam_height * (drag_margin_top - 0.5):
		# Character reaches the top drag margin.
		new_camera_pos.y = y_pos + cam_height * (0.5 - drag_margin_top)
	
	# Clamp the new camera position within the limits.
	new_camera_pos.x = clamp(new_camera_pos.x, left_limit + cam_width * 0.5, right_limit - cam_width * 0.5)
	new_camera_pos.y = clamp(new_camera_pos.y, top_limit + cam_height * 0.5, bottom_limit - cam_height * 0.5)
	
	target_pos = new_camera_pos

# Actually scroll the screen (update the viewport according to the position of the camera).
func update_viewport():
	var canvas_transform = get_viewport().canvas_transform
	canvas_transform.origin = -global_position / ZOOM_FACTOR + screen_size / 2.0
	get_viewport().canvas_transform = canvas_transform

# Pass in the intended position of an object. Returns the position clamped within the viewing bounds of the camera.
func clamp_pos_within_cam_bounds(pos):
	pos.x = clamp(pos.x, global_position.x - cam_width * 0.5, global_position.x + cam_width * 0.5)
	pos.y = clamp(pos.y, global_position.y - cam_height * 0.5, global_position.y + cam_height * 0.5)
	return pos

func instance_bottom_grab(pos_x):
	var fist = bottom_grab.instance()
	$"..".add_child(fist)
	fist.global_position = Vector2(pos_x, global_position.y + cam_height * 0.5)

func instance_top_fist():
	var fist = top_fist.instance()
	add_child(fist)
	fist.global_position = Vector2(global_position.x, global_position.y - cam_height * 0.5)

	return fist

func update_right_margin(value):
	drag_margin_right = value

func update_left_margin(value):
	drag_margin_left = value

func update_top_margin(value):
	drag_margin_top = value

func update_bottom_margin(value):
	drag_margin_bottom = value

func update_left_limit(value):
	left_limit = value

func update_right_limit(value):
	right_limit = value

func update_top_limit(value):
	top_limit = value

func update_bottom_limit(value):
	bottom_limit = value