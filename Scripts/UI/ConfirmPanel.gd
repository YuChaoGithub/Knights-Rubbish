extends CanvasLayer

var title
var target
var no_func
var yes_func

var pressed = false

func initialize(title, target, yes_func, no_func):
	self.title = title
	self.target = target
	self.no_func = no_func
	self.yes_func = yes_func

func _ready():
	$"ColorRect/Note Pad/Title".text = title
	$"ColorRect/Note Pad/No".connect("pressed", self, "no_pressed")
	$"ColorRect/Note Pad/Yes".connect("pressed", self, "yes_pressed")

func no_pressed():
	if !pressed:
		pressed = true
		target.call(no_func)

		play_quit_animation()

func yes_pressed():
	if !pressed:
		pressed = true
		target.call(yes_func)

		play_quit_animation()

func play_quit_animation():
	# queue_free() will be called in Quit animation.
	$ColorRect/AnimationPlayer.play("Quit")