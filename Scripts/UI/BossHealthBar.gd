extends CanvasLayer

export(Texture) var avatar_texture

const SMOOTH = 3.0

var actual_value

onready var bar = get_node("Container/Health Bar")
onready var animator = get_node("AnimationPlayer")

func _ready():
	animator.play("Hide")
	get_node("Container/Circular Frame/Avatar").set_texture(avatar_texture)
	actual_value = bar.get_value()
	set_process(true)

func _process(delta):
	bar.set_value(lerp(bar.get_value(), actual_value, delta * SMOOTH))

func show_health_bar():
	animator.play("Appear")

func drop_health_bar():
	animator.play("Disappear")

func set_health_bar_and_show(percentage):
	actual_value = int(percentage * 100.0)