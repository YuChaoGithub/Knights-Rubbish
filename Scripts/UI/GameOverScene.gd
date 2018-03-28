extends CanvasLayer

func _ready():
	get_tree().paused = true

func retry_pressed():
	get_node("/root/LoadingScene").reload_curr_scene()
	play_quit_animation()

func quit_pressed():
	# TODO: Go to door scene.
	play_quit_animation()

func play_quit_animation():
	get_tree().paused = false

	# queue_free() will be called in the Quit animation.
	$AnimationPlayer.play("Quit")