extends Node2D

const LIFETIME = 0.3

var timestamp = 0.0

func _ready():
	get_node("AnimationPlayer").play("Play")
	set_process(true)

func _process(delta):
	timestamp += delta

	if timestamp > LIFETIME:
		queue_free()