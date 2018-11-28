extends CanvasLayer

const RETRY_STRING = "Sure you want to retry?"
const QUIT_STRING = "Quit to main menu?"

var combo_tutorial_scene = preload("res://Scenes/UI/Combo Tutorial.tscn")
var key_setting_scene = preload("res://Scenes/UI/Key Setting Scene.tscn")
var confirm_panel = preload("res://Scenes/UI/Confirm Panel.tscn")

func _ready():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	get_tree().paused = true
	
	get_node("/root/Steamworks").increment_stat("paused")
	
func settings_pressed():
	add_child(key_setting_scene.instance())

func info_pressed():
	add_child(combo_tutorial_scene.instance())

func resume_pressed():
	play_quit_animation()

func retry_pressed():
	var ui = confirm_panel.instance()
	ui.initialize(RETRY_STRING, self, "retry_confirmed", "do_nothing")
	add_child(ui)

func retry_confirmed():
	get_node("/root/LoadingScene").reload_curr_scene()
	play_quit_animation()

func quit_pressed():
	var ui = confirm_panel.instance()
	ui.initialize(QUIT_STRING, self, "quit_confirmed", "do_nothing")
	add_child(ui)

func quit_confirmed():
	get_node("/root/LoadingScene").load_previous_scene()
	play_quit_animation()

func do_nothing():
	return

func play_quit_animation():
	get_tree().paused = false

	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	# queue_free() will be called in the Quit animation.
	$ColorRect/AnimationPlayer.play("Quit")