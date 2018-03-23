extends TextureButton

export(Color) var hover_color
export(Color) var press_color

onready var static_color = modulate

func _ready():
    connect("mouse_entered", self, "on_mouse_entered")
    connect("mouse_exited", self, "on_mouse_exited")
    connect("button_down", self, "on_mouse_pressed")
    connect("button_up", self, "on_mouse_released")

func on_mouse_entered():
    modulate = hover_color

func on_mouse_exited():
    modulate = static_color

func on_mouse_pressed():
    modulate = press_color

func on_mouse_released():
    modulate = static_color