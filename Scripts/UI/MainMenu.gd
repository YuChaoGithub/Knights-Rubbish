extends CanvasLayer

const SELF_SCENE_PATH = "res://Scenes/UI/Menu.tscn"
const HERO_SELECTION_SCENE_PATH = "res://Scenes/UI/Hero Choosing Scene.tscn"
const LEVEL_PICKER_SCENE_PATH = "res://Scenes/Levels/Level 1-0.tscn"

var confirm_panel = preload("res://Scenes/UI/Confirm Panel.tscn")

func single_player_pressed():
    get_node("/root/PlayerSettings").player_count = 1
    load_level_picker_scene()

func coop_pressed():
    get_node("/root/PlayerSettings").player_count = 2
    load_level_picker_scene()

func load_level_picker_scene():
    var loading_scene = get_node("/root/LoadingScene")
    loading_scene.quit_to_scene_path = SELF_SCENE_PATH
    loading_scene.next_scene_path = LEVEL_PICKER_SCENE_PATH
    loading_scene.goto_scene(HERO_SELECTION_SCENE_PATH)

func arena_pressed():
    pass

func quit_pressed():
    var panel = confirm_panel.instance()
    panel.initialize("Sure you want to quit?", self, "yes_func", "no_func")
    add_child(panel)

func yes_func():
    get_tree().quit()

func no_func():
    pass