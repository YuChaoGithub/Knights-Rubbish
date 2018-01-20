extends Node2D

# The limits which will be set to the camera upon the characters arriving the level part.
export(float) var cam_init_left_bound = -10000000000.0
export(float) var cam_init_right_bound = 10000000000.0
export(float) var cam_init_top_bound = -10000000000.0
export(float) var cam_init_bot_bound = 10000000000.0

# The margins which will be set to the camera upon the characters arriving the level part.
export(float) var cam_init_left_margin = 0.0
export(float) var cam_init_right_margin = 1.0
export(float) var cam_init_top_margin = 0.0
export(float) var cam_init_bot_margin = 1.0

# The level parts which should be removed/instanced upon the characters arriving the level part.
export(NodePath) var part_to_remove = "Null"
export(NodePath) var part_to_instance = "Null"

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
    if part_to_instance != "Null":
        get_node(part_to_instance).replace_by_instance()

    # Remove the existing scene (level part).
    if part_to_remove != "Null":
        get_node(part_to_remove).queue_free()

# These functions are useful for signal hooks.
func update_left_bound(val):
    following_camera.left_limit = val

func update_right_bound(val):
    following_camera.right_limt = val

func update_top_bound(val):
    following_camera.top_limit = val

func update_bottom_bount(val):
    following_camera.bottom_limit = val

func update_left_margin(val):
    following_camera.drag_margin_left = val

func update_right_margin(val):
    following_camera.drag_margin_right = val

func update_top_margin(val):
    following_camera.drag_margin_top = val

func update_bottom_margin(val):
    following_camera.drag_margin_bottom = val