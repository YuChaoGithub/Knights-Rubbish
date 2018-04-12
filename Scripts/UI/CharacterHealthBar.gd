extends CanvasLayer

const SMOOTH = 3.0
const SCRAP_COLOR = Color(1.0, 1.0, 1.0)
const ULT_SCRAP_COLOR = Color(0.7, 1.0, 1.0)

const HEALTH_BAR_POSITIONS_Y = [3, 80]

var actual_value
var dead_actual_value

var ordinary_frame_texture = preload("res://Graphics/UI/Circular Frame.png")
var ult_frame_texture = preload("res://Graphics/UI/Ult Frame.png")

onready var frame = $"Control/Frame"
onready var avatar = frame.get_node("Character")
onready var scrap_paper = $"Control/Scrap Paper"
onready var bar = $"Control/Bar"
onready var health_left_label = $"Control/Health Left"
onready var total_health_label = $"Control/Total Health"
onready var dead_health_bar = $DeadControl/Bar
onready var dead_health_label = $DeadControl/Value
onready var animator = $AnimationPlayer

func initialize(full_value, ghost_full_value, avatar_texture):
	actual_value = full_value
	dead_actual_value = 0
	health_left_label.text = str(full_value)
	total_health_label.text = str(full_value)

	avatar.texture = avatar_texture

	bar.max_value = full_value
	bar.value = full_value
	dead_health_bar.max_value = ghost_full_value
	dead_health_bar.value = 0

func set_health_bar_position(player_index):
	$Control.rect_position.y = HEALTH_BAR_POSITIONS_Y[player_index]
	$DeadControl.rect_position.y = HEALTH_BAR_POSITIONS_Y[player_index]

func set_health_bar(value):
	actual_value = value

	health_left_label.text = str(value)

func set_dead_health(value):
	dead_actual_value = value

	dead_health_label.text = str(value)

func _process(delta):
		bar.value = lerp(bar.value, actual_value, delta * SMOOTH)
		dead_health_bar.value = lerp(dead_health_bar.value, dead_actual_value, delta * SMOOTH)

func change_to_ult_theme():
	frame.texture = ult_frame_texture
	scrap_paper.self_modulate = ULT_SCRAP_COLOR

func change_to_ordinary_theme():
	frame.texture = ordinary_frame_texture
	scrap_paper.self_modulate = SCRAP_COLOR

func switch_to_dead_health_bar():
	animator.play("Dead Control Fade")

func switch_from_dead_to_original_health_bar():
	animator.play_backwards("Dead Control Fade")