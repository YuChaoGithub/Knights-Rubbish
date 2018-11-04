extends TextureButton

export(int, "SinglePlayer", "Coop") var mode_index
export(int, "P1", "P2") var player_index
export(int, "Attack", "Skill", "Jump", "Ult", "Up", "Down", "Left", "Right") var action_index

const player_strings = ["p1", "p2"]
const action_strings = ["attack", "skill", "jump", "ult", "up", "down", "left", "right"]

const BUTTON_AUDIO_VOLUME = -5

const KEY_STRING_MAP = {
    QuoteLeft = "Quote",
    Minus = "-",
    Equal = "=",
    BackSpace = "Bkspce",
    BraceLeft = "L Brace",
    BraceRight = "R Brace",
    BackSlash = "Bkslash",
    Semicolon = ";",
    Period = ".",
    Comma = ",",
    Slash = "/",
    Command = "Cmd",
    Apostrophe = "Apstrph",
    Control = "Ctrl"
}

const ORIGINAL_COLOR = Color(0.0, 0.0, 0.0)
const HOVER_COLOR = Color(28.0 / 255.0, 132.0 / 255.0, 255.0 / 255.0)
const CONFIGURE_COLOR = Color(255.0 / 255.0, 0.0, 0.0)

onready var label = $Label

var pending_input = false
var action_key

var click_sound = preload("res://Audio/button_click.wav")
var hover_sound = preload("res://Audio/button_hover.wav")
var success_sound = preload("res://Audio/success.wav")
var error_sound = preload("res://Audio/error.wav")

var audio_player

func _ready():
    audio_player = AudioStreamPlayer.new()
    audio_player.volume_db = BUTTON_AUDIO_VOLUME
    add_child(audio_player)

    # Remove if the mode doesn't match.
    if mode_index + 1 != get_node("/root/PlayerSettings").player_count:
        queue_free()
        return

    connect("mouse_entered", self, "on_mouse_entered")
    connect("mouse_exited", self, "on_mouse_exited")
    connect("pressed", self, "on_pressed")

    action_key = player_strings[player_index] + "_" + action_strings[action_index]

    # Configure label.
    var action_list = InputMap.get_action_list(action_key)
    for event in action_list:
        if event is InputEventKey:
            var event_string = OS.get_scancode_string(event.scancode)
            label.text = map_to_key_string(event_string)
            $"../..".used_keys.push_back(event_string)
            break

    set_process_input(false)

func _input(event):
    if event is InputEventKey:
        var event_string = OS.get_scancode_string(event.scancode)
        
        # Avoid mapping the same key to different actions.
        if event_string in $"../..".used_keys:
            audio_player.stream = error_sound
            audio_player.play()
            return

        # Configure label.
        label.text = map_to_key_string(event_string)
        
        # Configure InputMap.
        add_new_event(event)
        
        end_pending_input()

        audio_player.stream = success_sound
        audio_player.play()

func on_mouse_entered():
    audio_player.stream = hover_sound
    audio_player.play()

    if !pending_input:
        modulate = HOVER_COLOR

func on_mouse_exited():
    if !pending_input:
        modulate = ORIGINAL_COLOR

func on_pressed():
    audio_player.stream = click_sound
    audio_player.play()

    if !pending_input:
        remove_old_events()
        start_pending_input()

func start_pending_input():
    pending_input = true
    modulate = CONFIGURE_COLOR
    label.visible = false
    
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
    
    $"../..".start_configuring()
    set_process_input(true)

func end_pending_input():
    pending_input = false
    modulate = ORIGINAL_COLOR
    label.visible = true

    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

    $"../..".end_configuring()
    set_process_input(false)

    # To lose focus. (Avoid configuring again when gui controlling keys such as Enter or Space are pressed.)
    visible = false
    visible = true

func map_to_key_string(original):
    if KEY_STRING_MAP.has(original):
        return KEY_STRING_MAP[original]
    elif original == "Alt" && OS.get_name() == "OSX":
        return "Option"
    else:
        return original

func remove_old_events():
    var action_list = InputMap.get_action_list(action_key)
    for event in action_list:
        if event is InputEventKey:
            $"../..".used_keys.erase(OS.get_scancode_string(event.scancode))
            InputMap.action_erase_event(action_key, event)

func add_new_event(event):
    InputMap.action_add_event(action_key, event)
    $"../..".used_keys.push_back(OS.get_scancode_string(event.scancode))