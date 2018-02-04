extends Position2D

signal passed

enum { NONE, LESSER, GREATER }

# Determines whether to trigger level part entering events when Character Average Position is less than or greater than the entery point.
export(int, "None", "Lesser", "Greater") var x_check = 2
export(int, "None", "Lesser", "Greater") var y_check = 0

onready var char_average_pos = get_node("../../../Character Average Position")
onready var level_part = get_node("..")

func _ready():
	set_process(true)

func _process(delta):
	var success_x = x_check == NONE || (x_check == GREATER && char_average_pos.get_global_pos().x > get_global_pos().x) || (x_check == LESSER && char_average_pos.get_global_pos().x < get_global_pos().x)
	var success_y = y_check == NONE || (y_check == GREATER && char_average_pos.get_global_pos().y > get_global_pos().y) || (y_check == LESSER && char_average_pos.get_global_pos().y < get_global_pos().y)

	# If both x and y of Character Average Position moved pass the point,
	# trigger level part entering event and remove itself.
	if success_x && success_y:
		emit_signal("passed")
		queue_free()