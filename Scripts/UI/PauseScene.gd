extends CanvasLayer

const RETRY_STRING = "Sure you want to retry?"
const QUIT_STRING = "Sure you want to quit?"

var confirm_panel = preload("res://Scenes/UI/Confirm Panel.tscn")

func _ready():
	get_tree().paused = true

func settings_pressed():
	# TODO: Show settings scene.
	pass

func resume_pressed():
	play_quit_animation()

func retry_pressed():
	var ui = confirm_panel.instance()
	ui.initialize(RETRY_STRING, self, "retry_confirmed", "do_nothing")
	add_child(ui)

func retry_confirmed():
	# TODO: Reload current level.
	play_quit_animation()

func quit_pressed():
	var ui = confirm_panel.instance()
	ui.initialize(QUIT_STRING, self, "quit_confirmed", "do_nothing")
	add_child(ui)

func quit_confirmed():
	# TODO: Go to door scene.
	play_quit_animation()

func do_nothing():
	return

func play_quit_animation():
	get_tree().paused = false

	# queue_free() will be called in the Quit animation.
	$ColorRect/AnimationPlayer.play("Quit")