extends CanvasLayer

var confirm_panel = preload("res://Scenes/UI/Confirm Panel.tscn")
var QUIT_STRING = "Sure you want to quit?"

func _ready():
	get_tree().paused = true

func retry_pressed():
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

	# queue_free() will be called in the Quit animation.
	$AnimationPlayer.play("Quit")