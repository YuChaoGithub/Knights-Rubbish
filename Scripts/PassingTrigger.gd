extends Position2D

signal passed

enum { NONE, LESSER, GREATER }

# Will only be triggered if a character is in the range.
# (To avoid triggering multiple PassingTriggers while testing.)
export(int) var range_x = 1000
export(int) var range_y = 1000

# Determines whether to trigger level part entering events when Character Average Position is less than or greater than the entery point.
export(int, "None", "Lesser", "Greater") var x_check = 2
export(int, "None", "Lesser", "Greater") var y_check = 0

var in_range = false

onready var char_average_pos = $"../../Character Average Position"

func _process(delta):
	if in_range:
		var success_x = x_check == NONE || (x_check == GREATER && char_average_pos.global_position.x > global_position.x) || (x_check == LESSER && char_average_pos.global_position.x < global_position.x)
		var success_y = y_check == NONE || (y_check == GREATER && char_average_pos.global_position.y > global_position.y) || (y_check == LESSER && char_average_pos.get_max_y() < global_position.y)

		# If both x and y of Character Average Position moved pass the point,
		# trigger level part entering event and remove itself.
		if success_x && success_y:
			emit_signal("passed")
			queue_free()
	elif char_average_pos.in_range_of(global_position, range_x, range_y):
		in_range = true