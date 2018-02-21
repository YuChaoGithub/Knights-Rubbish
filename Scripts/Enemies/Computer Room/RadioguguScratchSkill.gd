extends Node2D

const LIFETIME = 1.5

var lifetime_timestamp

func _ready():
	lifetime_timestamp = 0
	$AnimationPlayer.play("Scratch")

func _process(delta):
	lifetime_timestamp += delta
	if lifetime_timestamp >= LIFETIME:
		queue_free()