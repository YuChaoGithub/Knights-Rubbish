extends TextureButton

export(Color) var hover_color
export(Color) var press_color

const BUTTON_AUDIO_VOLUME = -5

var click_sound = preload("res://Audio/button_click.wav")
var hover_sound = preload("res://Audio/button_hover.wav")

onready var static_color = modulate

var audio_player

func _ready():
    audio_player = AudioStreamPlayer.new()
    audio_player.volume_db = BUTTON_AUDIO_VOLUME
    add_child(audio_player)

    connect("mouse_entered", self, "on_mouse_entered")
    connect("mouse_exited", self, "on_mouse_exited")
    connect("button_down", self, "on_mouse_pressed")
    connect("button_up", self, "on_mouse_released")

func on_mouse_entered():
    audio_player.stream = hover_sound
    audio_player.play()
    modulate = hover_color

func on_mouse_exited():
    modulate = static_color

func on_mouse_pressed():
    audio_player.stream = click_sound
    audio_player.play()
    modulate = press_color

func on_mouse_released():
    modulate = static_color