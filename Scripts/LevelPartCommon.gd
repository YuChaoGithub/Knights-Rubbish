extends Node2D

# The limits which will be set to the camera upon the characters arriving the level part.
export(int) var cam_init_left_bound = -1000000
export(int) var cam_init_right_bound = 1000000
export(int) var cam_init_top_bound = -100000
export(int) var cam_init_bot_bound = 1000000

# The margins which will be set to the camera upon the characters arriving the level part.
export(float) var cam_init_left_margin = 0.0
export(float) var cam_init_right_margin = 1.0
export(float) var cam_init_top_margin = 0.0
export(float) var cam_init_bot_margin = 1.0

# The level parts which should be removed/instanced upon the characters arriving the level part.
export(NodePath) var part_to_remove
export(NodePath) var part_to_instance

onready var following_camera = get_node("../../Following Camera")

# Will be called by LevelPartEntryPoint.gd when the Character Average Position enters the level part.
func character_entered():
    # Update the new camera movement scheme.
    following_camera.left_limit = cam_init_left_bound
    following_camera.right_limit = cam_init_right_bound
    following_camera.top_limit = cam_init_top_bound
    following_camera.bottom_limit = cam_init_bot_bound

    following_camera.drag_margin_left = cam_init_left_margin
    following_camera.drag_margin_right = cam_init_right_margin
    following_camera.drag_margin_top = cam_init_top_margin
    following_camera.drag_margin_bottom = cam_init_bot_margin

    # Instance the placeholder scene (level part).
    get_node(part_to_instance).replace_by_instance()

    # Remove the existing scene (level part).
    get_node(part_to_remove).queue_free()