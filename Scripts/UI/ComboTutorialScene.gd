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