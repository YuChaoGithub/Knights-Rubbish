extends Node

func _ready():
    preload("res://Scripts/Utils/RandomNumberGenerator.gd").init_rand()

    remove_default_ui_actions()
    read_key_config()

func remove_default_ui_actions():
    for action in ["ui_accept","ui_select","ui_cancel","ui_focus_next","ui_focus_prev","ui_left","ui_right","ui_up","ui_down","ui_page_up","ui_page_down"]:
        if InputMap.has_action(action):
            InputMap.erase_action(action);
        InputMap.add_action(action); # To avoid reading complaints about  "Request for nonexistent InputMap action:ui_xxx"
        
func read_key_config():
    var save_file = File.new()
    if !save_file.file_exists("user://keysettings.save"):
        save_key_config()
        return

    save_file.open("user://keysettings.save", File.READ)

    var dic = parse_json(save_file.get_line())
    for action in dic:
        erase_all_events_in_action(action)

        var event = InputEventKey.new()
        event.scancode = dic[action]
        InputMap.action_add_event(action, event)

    save_file.close()
        
func save_key_config():
    var save_file = File.new()
    save_file.open("user://keysettings.save", File.WRITE)
    save_file.store_line(to_json(get_key_config_dic()))
    save_file.close()
        
func get_key_config_dic():
    var dic = {}
    for action in InputMap.get_actions():
        for event in InputMap.get_action_list(action):
            dic[action] = event.scancode

    return dic

func erase_all_events_in_action(action):
    var events = InputMap.get_action_list(action)
    for e in events:
        InputMap.action_erase_event(action, e)