extends Position2D

# Determines whether to trigger level part entering events when Character Average Position is less than or greater than the entery point.
export(bool) var x_greater_than = true
export(bool) var y_greater_than = false

onready var char_average_pos = get_node("../../../Character Average Position")
onready var level_part = get_node("..")

func _ready():
	set_process(true)

func _process(delta):
	var success_x = false
	var success_y = false

	# Check if the x position of Character Average Position moved pass the point.
	if x_greater_than && char_average_pos.get_global_pos().x > get_global_pos().x:
		success_x = true
	elif !x_greater_than && char_average_pos.get_global_pos().x < get_global_pos().x:
		success_x = true

	# Check if the y position of Character Average Position moved pass the point.
	if y_greater_than && char_average_pos.get_global_pos().y > get_global_pos().y:
		success_y = true
	elif !y_greater_than && char_average_pos.get_global_pos().y < get_global_pos().y:
		success_y = true

	# If both x and y of Character Average Position moved pass the point,
	# trigger level part entering event and remove itself.
	if success_x && success_y:
		level_part.character_entered()
		queue_free()