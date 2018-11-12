extends Node

const FILE_PATH = "user://no_delete_please.save"

var level_available = {
    latortrans = 1,
    amazlet = 0,
    radiogugu = 0,
    godotbos = 0,
    eyemac = 0,
    realfake = 0
}

func _ready():
    read_level_data()

func read_level_data():
    var save_file = File.new()
    if !save_file.file_exists(FILE_PATH):
        save_level_data()
        return

    save_file.open(FILE_PATH, File.READ)
    level_available = parse_json(save_file.get_line())
    save_file.close()

func save_level_data():
    var save_file = File.new()
    save_file.open(FILE_PATH, File.WRITE)
    save_file.store_line(to_json(level_available))
    save_file.close()

func screen_capture(slot):
    get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)

    yield(get_tree(), "idle_frame")
    yield(get_tree(), "idle_frame")

    var img = get_viewport().get_texture().get_data()
    img.flip_y()

    img.save_png("user://screenshot" + str(slot) + ".png")