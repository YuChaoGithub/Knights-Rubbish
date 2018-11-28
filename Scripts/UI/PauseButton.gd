extends CanvasLayer

var pause_scene = preload("res://Scenes/UI/Pause Scene.tscn")

func _ready():
	$ScrapPaper/PauseButton.connect("pressed", self, "pause_pressed")
	
	if Steam.isSteamRunning():
		Steam.connect("_overlay_toggled", self, "pause_pressed")

func pause_pressed():
	if !get_tree().paused:
		var ui = pause_scene.instance()
		add_child(ui)