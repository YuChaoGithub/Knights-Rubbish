extends CanvasLayer

var timestamp = 0.0

func _ready():
	get_tree().paused = true
	get_node("/root/Steamworks").increment_stat("gameover")
	
func _process(delta):
	timestamp += delta
	if timestamp >= 60.0:
		timestamp -= 60.0
		get_node("/root/Steamworks").increment_stat("stay_in_gameover")

func retry_pressed():
	get_node("/root/LoadingScene").reload_curr_scene()
	play_quit_animation()

func quit_pressed():
	get_node("/root/LoadingScene").load_quit_scene()
	play_quit_animation()

func play_quit_animation():
	get_tree().paused = false

	# queue_free() will be called in the Quit animation.
	$AnimationPlayer.play("Quit")