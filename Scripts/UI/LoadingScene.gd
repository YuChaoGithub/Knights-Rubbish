extends Node

const MAX_BLOCK_TIME = 50

var curr_scene_path
var quit_to_scene_path
var loading_scene_instance
var animator
var loader
var current_scene
var wait_frames

func _ready():
    pause_mode = PAUSE_MODE_PROCESS
    var root = get_tree().get_root()
    current_scene = root.get_child(root.get_child_count() - 1)

func reload_curr_scene():
    goto_scene(curr_scene_path)

func load_quit_scene():
    goto_scene(quit_to_scene_path)

func goto_scene(path):
    get_tree().paused = true
    loading_scene_instance = preload("res://Scenes/UI/Loading Scene.tscn").instance()
    animator = loading_scene_instance.get_node("Background/AnimationPlayer")
    add_child(loading_scene_instance)

    loader = ResourceLoader.load_interactive(path)
    if loader == null:
        show_error()
        return
    set_process(true)

    current_scene.queue_free()

    wait_frames = 1

func _process(delta):
    if loader == null:
        set_process(false)
        return
    
    # Wat for the loading scene to show up.
    if wait_frames > 0:
        wait_frames -= 1
        return

    var t = OS.get_ticks_msec()
    while OS.get_ticks_msec() < t + MAX_BLOCK_TIME:
        var result = loader.poll()

        if result == ERR_FILE_EOF:
            var resource = loader.get_resource()
            loader = null
            set_new_scene(resource)
            break
        elif result == OK:
            pass
        else:
            show_error()
            loader = null
            break

func set_new_scene(scene_resource):
    current_scene = scene_resource.instance()
    get_node("/root").add_child(current_scene)

    # queue_free will be called at the end of the Exit animation.
    animator.play("Exit")

    get_tree().paused = false