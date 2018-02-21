extends CanvasLayer

const SMOOTH = 3.0
const SCRAP_COLOR = Color(1.0, 1.0, 1.0)
const ULT_SCRAP_COLOR = Color(0.7, 1.0, 1.0)

var actual_value

var ordinary_frame_texture = preload("res://Graphics/UI/Circular Frame.png")
var ult_frame_texture = preload("res://Graphics/UI/Ult Frame.png")

onready var frame = $"Control/Frame"
onready var avatar = frame.get_node("Character")
onready var scrap_paper = $"Control/Scrap Paper"
onready var bar = $"Control/Bar"
onready var health_left_label = $"Control/Health Left"
onready var total_health_label = $"Control/Total Health"

func initialize(full_value, avatar_texture):
	actual_value = full_value
	health_left_label.text = str(full_value)
	total_health_label.text = str(full_value)

	avatar.texture = avatar_texture

	bar.max_value = full_value
	bar.value = full_value

func set_health_bar(value):
	actual_value = value
	health_left_label.text = str(value)

func _process(delta):
	bar.value = lerp(bar.value, actual_value, delta * SMOOTH)

func change_to_ult_theme():
	frame.texture = ult_frame_texture
	scrap_paper.modulate = ULT_SCRAP_COLOR

func change_to_ordinary_theme():
	frame.texture = ordinary_frame_texture
	scrap_paper.modulate = SCRAP_COLOR