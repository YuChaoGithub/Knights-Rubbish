extends CanvasLayer

const SELF_SCENE_PATH = "res://Scenes/UI/Menu.tscn"
const HERO_SELECTION_SCENE_PATH = "res://Scenes/UI/Hero Choosing Scene.tscn"
const LEVEL_PICKER_SCENE_PATH = "res://Scenes/Levels/Level Picker.tscn"
const KEY_SETTING_SCENE_PATH = "res://Scenes/UI/Key Setting Scene.tscn"

var timestamp = 0.0
var confirm_panel = preload("res://Scenes/UI/Confirm Panel.tscn")

onready var loading_scene = get_node("/root/LoadingScene")

func _ready():
    if loading_scene.scene_path_stack.empty():
        loading_scene.scene_path_stack.push_back(SELF_SCENE_PATH)

func _process(delta):
    timestamp += delta
    if timestamp >= 60.0:
        timestamp -= 60.0
        get_node("/root/Steamworks").increment_stat("stay_in_menu")

func single_player_pressed():
    get_node("/root/PlayerSettings").player_count = 1
    load_hero_selection_scene()

func coop_pressed():
    get_node("/root/PlayerSettings").player_count = 2
    load_hero_selection_scene()

func load_hero_selection_scene():
    loading_scene.next_scene_path = LEVEL_PICKER_SCENE_PATH
    loading_scene.load_scene(HERO_SELECTION_SCENE_PATH)

func setting_button_pressed():
    loading_scene.load_scene(KEY_SETTING_SCENE_PATH)

func arena_pressed():
    pass

func quit_pressed():
    var panel = confirm_panel.instance()
    panel.initialize("Sure you want to quit?", self, "yes_func", "no_func")
    add_child(panel)

func yes_func():
    get_node("/root/Steamworks").quit_steamworks()
    get_tree().quit()

func no_func():
    pass