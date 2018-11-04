extends Node

func _ready():
	preload("res://Scripts/Utils/RandomNumberGenerator.gd").init_rand()
	
	remove_default_ui_actions()

func remove_default_ui_actions():
    for action in ["ui_accept","ui_select","ui_cancel","ui_focuse_next","ui_focus_prev","ui_left","ui_right","ui_up","ui_down","ui_page_up","ui_page_down"]:
        if InputMap.has_action(action):
            InputMap.erase_action(action);
        InputMap.add_action(action); # To avoid reading complaints about  "Request for nonexistent InputMap action:ui_xxx"