extends CanvasLayer

var pause_scene = preload("res://Scenes/UI/Pause Scene.tscn")

func _ready():
	$ScrapPaper/PauseButton.connect("pressed", self, "pause_pressed")

func pause_pressed():
	var ui = pause_scene.instance()
	add_child(ui)