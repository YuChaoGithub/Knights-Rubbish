extends Control

export(String) var url

func _ready():
    connect("pressed", self, "goto_link")

func goto_link():
    OS.shell_open(url)