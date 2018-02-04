extends Node2D

onready var following_camera = get_node("../../Following Camera")

func instance_level_part(name):
    get_node("../../" + name + "/Scene").replace_by_instance()

func remove_level_part(name):
    get_node("../../" + name).queue_free()

# These functions are useful for signal hooks.
func update_left_bound(val):
    following_camera.left_limit = val

func update_right_bound(val):
    following_camera.right_limit = val

func update_top_bound(val):
    following_camera.top_limit = val

func update_bottom_bound(val):
    following_camera.bottom_limit = val

func update_left_margin(val):
    following_camera.drag_margin_left = val

func update_right_margin(val):
    following_camera.drag_margin_right = val

func update_top_margin(val):
    following_camera.drag_margin_top = val

func update_bottom_margin(val):
    following_camera.drag_margin_bottom = val