extends Control

const CONFIRM_PANEL_TEXT = "Quit to main menu?"

var key_setting_scene = preload("res://Scenes/UI/Key Setting Scene.tscn")
var combo_tutorial_scene = preload("res://Scenes/UI/Combo Tutorial.tscn")
var confirm_panel = preload("res://Scenes/UI/Confirm Panel.tscn")

func setting_pressed():
    add_child(key_setting_scene.instance())

func info_pressed():
    add_child(combo_tutorial_scene.instance())

func quit_pressed():
    var ui = confirm_panel.instance()
    ui.initialize(CONFIRM_PANEL_TEXT, self, "quit_confirmed", "do_nothing")
    add_child(ui)

func quit_confirmed():
    get_node("/root/LoadingScene").load_previous_scene()

func do_nothing():
    pass