extends CanvasLayer

const SMOOTH = 3.0

var actual_value

onready var bar = get_node("Control/Bar")
onready var health_left_label = get_node("Control/Health Left")
onready var total_health_label = get_node("Control/Total Health")

func initialize(full_value):
	actual_value = full_value
	health_left_label.set_text(str(full_value))
	total_health_label.set_text(str(full_value))

	bar.set_max(full_value)
	bar.set_value(full_value)

	set_process(true)

func set_health_bar(value):
	actual_value = value
	health_left_label.set_text(str(value))

func _process(delta):
	bar.set_value(lerp(bar.get_value(), actual_value, delta * SMOOTH))