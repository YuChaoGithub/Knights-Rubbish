extends Node2D

const CAMERA_SMOOTH = 3.0
const ZOOM_FACTOR = 3.0

# Drag margins (from 0 to 1).
export(float) var drag_margin_right = 0.5
export(float) var drag_margin_left = 0.3
export(float) var drag_margin_top = 0.5
export(float) var drag_margin_bottom = 0.8

# Max/Min limits of the camera position (+ margin).
var right_limit = 1000000
var left_limit = -1000000
var top_limit = -1000000
var bottom_limit = 1000000

# Limit the character from going back to the edge it comes from.
var is_limiting_right = false
var is_limiting_left = false
var is_limiting_top = false
var is_limiting_bottom = false

# The target position for the camera.
onready var target_pos = get_global_pos()

# A Vector2 storing the screen size.
onready var screen_size = get_viewport_rect().size

func _ready():
	# Initialize the zooming of the viewport.
	var canvas_transform = get_viewport().get_canvas_transform()
	canvas_transform.x /= ZOOM_FACTOR
	canvas_transform.y /= ZOOM_FACTOR
	get_viewport().set_canvas_transform(canvas_transform)
	
	set_process(true)
	
func _process(delta):
	# Move the camera closer to its target position.
	var new_pos_x = lerp(get_global_pos().x, target_pos.x, delta * CAMERA_SMOOTH)
	var new_pos_y = lerp(get_global_pos().y, target_pos.y, delta * CAMERA_SMOOTH)
	set_global_pos(Vector2(new_pos_x, new_pos_y))
	
	# Actually move the viewport.
	update_viewport()
	
# Detmermine whether or not to update the camera according to the position of the character.
# This function should be called by the player movement script.
func check_camera_update(character_pos):
	var new_camera_pos = get_global_pos()
	
	# Check if the character reaches the horizontal margins. If so, update the position of the camera.
	if character_pos.x > get_global_pos().x + screen_size.width * ZOOM_FACTOR * (drag_margin_right - 0.5):
		# Character reaches the right drag margin.
		new_camera_pos.x = character_pos.x - screen_size.width * ZOOM_FACTOR * (drag_margin_right - 0.5)
	elif character_pos.x < get_global_pos().x + screen_size.width * ZOOM_FACTOR * (drag_margin_left - 0.5):
		# Character reaches the left drag margin.
		new_camera_pos.x = character_pos.x + screen_size.width * ZOOM_FACTOR * (0.5 - drag_margin_left)
	
	# Vertical margin checks.
	if character_pos.y > get_global_pos().y + screen_size.height * ZOOM_FACTOR * (drag_margin_bottom - 0.5):
		# Character reaches the bottom drag margin.
		new_camera_pos.y = character_pos.y - screen_size.height * ZOOM_FACTOR * (drag_margin_bottom - 0.5)
	elif character_pos.y < get_global_pos().y + screen_size.height * ZOOM_FACTOR * (drag_margin_top - 0.5):
		# Character reaches the top drag margin.
		new_camera_pos.y = character_pos.y + screen_size.height * ZOOM_FACTOR * (0.5 - drag_margin_top)
	
	# Clamp the new camera position within the limits.
	new_camera_pos.x = clamp(new_camera_pos.x, left_limit + screen_size.width * 0.5 * ZOOM_FACTOR, right_limit - screen_size.width * 0.5 * ZOOM_FACTOR)
	new_camera_pos.y = clamp(new_camera_pos.y, top_limit + screen_size.height * 0.5 * ZOOM_FACTOR, bottom_limit - screen_size.height * 0.5 * ZOOM_FACTOR)
	
	# Check if the character is limited from going backwards. If it is, update the limit to the current camera edge.
	if is_limiting_right:
		right_limit = new_camera_pos.x + screen_size.width * 0.5 * ZOOM_FACTOR
	if is_limiting_left:
		left_limit = new_camera_pos.x - screen_size.width * 0.5 * ZOOM_FACTOR
	if is_limiting_top:
		top_limit = new_camera_pos.y - screen_size.height * 0.5 * ZOOM_FACTOR
	if is_limiting_bottom:
		bottom_limit = new_camera_pos.y + screen_size.height * 0.5 * ZOOM_FACTOR
	
	target_pos = new_camera_pos
	
# Actually scroll the screen (update the viewport according to the position of the camera).
func update_viewport():
	var canvas_tranform = get_viewport().get_canvas_transform()
	canvas_tranform.o = -get_global_pos() / ZOOM_FACTOR + screen_size / 2.0
	get_viewport().set_canvas_transform(canvas_tranform)