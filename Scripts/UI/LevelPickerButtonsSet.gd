extends Control

const CONFIRM_PANEL_TEXT = "Quit to main menu?"

var key_setting_scene = preload("res://Scenes/UI/Key Setting Scene.tscn")
var combo_tutorial_scene = preload("res://Scenes/UI/Combo Tutorial.tscn")
var confirm_panel = preload("res://Scenes/UI/Confirm Panel.tscn")

func setting_pressed():
    var ks_scene = key_setting_scene.instance()
    ks_scene.resume_scene = self
    add_child(ks_scene)
    get_tree().paused = true

func info_pressed():
    var ct_scene = combo_tutorial_scene.instance()
    ct_scene.resume_scene = self
    add_child(ct_scene)
    get_tree().paused = true

func quit_pressed():
    var ui = confirm_panel.instance()
    ui.initialize(CONFIRM_PANEL_TEXT, self, "quit_confirmed", "do_nothing")
    add_child(ui)

func resume_current():
    get_tree().paused = false

func quit_confirmed():
    get_node("/root/LoadingScene").load_previous_scene()

func do_nothing():
    pass