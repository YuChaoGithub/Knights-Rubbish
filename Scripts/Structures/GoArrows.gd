extends Node2D

func _ready():
    self.visible = false

func activate():
    $Arrow.play()
    self.visible = true