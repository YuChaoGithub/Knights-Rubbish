extends CanvasLayer

export(Texture) var avatar_texture

const SMOOTH = 3.0

var actual_value

onready var bar = $"Container/Health Bar"
onready var animator = $AnimationPlayer

func _ready():
	animator.play("Hide")
	$"Container/Circular Frame/Avatar".texture = avatar_texture
	actual_value = bar.value

func _process(delta):
	bar.value = lerp(bar.value, actual_value, delta * SMOOTH)

func show_health_bar():
	animator.play("Appear")

func drop_health_bar():
	animator.play("Disappear")

func set_health_bar_and_show(percentage):
	actual_value = int(percentage * 100.0)