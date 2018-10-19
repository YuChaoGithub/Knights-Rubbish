extends Node

func screen_capture(slot):
    get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)

    yield(get_tree(), "idle_frame")
    yield(get_tree(), "idle_frame")

    var img = get_viewport().get_texture().get_data()
    img.flip_y()

    img.save_png("user://screenshot" + str(slot) + ".png")