extends CanvasLayer

onready var label1 = $WoodenBackground/Paper/Last/Label1
onready var label2 = $WoodenBackground/Paper/Last/Label2

func _ready():
    if OS.get_name() == "OSX":
        label1.text = "CMD"
        label2.text = "Q"
    else:
        label1.text = "ALT"
        label2.text = "F4"

func back_button_pressed():
    # queue_free() will be called in this animation.
    $AnimationPlayer.play("Leave")