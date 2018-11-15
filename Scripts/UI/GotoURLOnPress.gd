extends Control

export(String) var url

func _ready():
    connect("pressed", self, "goto_link")

func goto_link():
    get_node("/root/Steamworks").set_achievement("DEVELOPER")
    OS.shell_open(url)