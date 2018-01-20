extends CanvasLayer

const SMOOTH = 3.0
const SCRAP_COLOR = Color(1.0, 1.0, 1.0)
const ULT_SCRAP_COLOR = Color(0.7, 1.0, 1.0)

var actual_value

var ordinary_frame_texture = preload("res://Graphics/UI/Circular Frame.png")
var ult_frame_texture = preload("res://Graphics/UI/Ult Frame.png")

onready var frame = get_node("Control/Frame")
onready var avatar = frame.get_node("Character")
onready var scrap_paper = get_node("Control/Scrap Paper")
onready var bar = get_node("Control/Bar")
onready var health_left_label = get_node("Control/Health Left")
onready var total_health_label = get_node("Control/Total Health")

func initialize(full_value, avatar_texture):
	actual_value = full_value
	health_left_label.set_text(str(full_value))
	total_health_label.set_text(str(full_value))

	avatar.set_texture(avatar_texture)

	bar.set_max(full_value)
	bar.set_value(full_value)

	set_process(true)

func set_health_bar(value):
	actual_value = value
	health_left_label.set_text(str(value))

func _process(delta):
	bar.set_value(lerp(bar.get_value(), actual_value, delta * SMOOTH))

func change_to_ult_theme():
	frame.set_texture(ult_frame_texture)
	scrap_paper.set_modulate(ULT_SCRAP_COLOR)

func change_to_ordinary_theme():
	frame.set_texture(ordinary_frame_texture)
	scrap_paper.set_modulate(SCRAP_COLOR)