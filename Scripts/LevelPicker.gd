extends Node2D

onready var user_data = get_node("/root/UserDataSingleton")
onready var doors = $Doors
onready var icons = $Writings

func _ready():
    user_data.read_level_data()
    
    for name in user_data.level_available:
        if user_data.level_available[name] == 1:
            doors.get_node(name).modulate = Color(1, 1, 1, 1)
            if name != "realfake":
                doors.get_node(name).available = true
            icons.get_node(name).modulate = Color(1, 1, 1, 1)