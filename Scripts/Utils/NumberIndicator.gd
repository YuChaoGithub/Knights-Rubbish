extends Node2D

const MOVEMENT_Y = -100
const SHOW_DURATION = 0.25
const SPRITE_WIDTH = 75

enum { STUNNED = -1, IMMUNE = -2 }

var number_scenes = [
	preload("res://Scenes/Utils/Numbers/Number 0.tscn"),
	preload("res://Scenes/Utils/Numbers/Number 1.tscn"),
	preload("res://Scenes/Utils/Numbers/Number 2.tscn"),
	preload("res://Scenes/Utils/Numbers/Number 3.tscn"),
	preload("res://Scenes/Utils/Numbers/Number 4.tscn"),
	preload("res://Scenes/Utils/Numbers/Number 5.tscn"),
	preload("res://Scenes/Utils/Numbers/Number 6.tscn"),
	preload("res://Scenes/Utils/Numbers/Number 7.tscn"),
	preload("res://Scenes/Utils/Numbers/Number 8.tscn"),
	preload("res://Scenes/Utils/Numbers/Number 9.tscn")
]
var stunned_scene = preload("res://Scenes/Utils/Numbers/Stunned.tscn")
var immune_scene = preload("res://Scenes/Utils/Numbers/Immune.tscn")

var number_instances = []
var timepassed = 0.0
var color
var parent

onready var start_pos = get_global_pos()

# Pass in -1 to show "Stunned!".
func initialize(number, color, pos, node):
	self.color = color

	parent = node.get_tree().get_root().get_node("Game Level")
	 
	set_global_pos(pos.get_curr_pos(self))

	if number == STUNNED:
		instance_stunned_text()
	elif number == IMMUNE || number == 0:
		instance_immune_text()
	else:
		instance_numbers(number)		
	
	settle_positions()
	add_numbers_as_children()

	parent.add_child(self)

	set_process(true)

func instance_numbers(number):
	while number > 0:
		var new_num = number_scenes[int(number) % 10].instance()
		number_instances.push_back(new_num)
		number = int(number / 10)

func instance_stunned_text():
	var stunned_text = stunned_scene.instance()
	number_instances.push_back(stunned_text)

func instance_immune_text():
	var immune_text = immune_scene.instance()
	number_instances.push_back(immune_text)

func settle_positions():
	var len = number_instances.size()
	var half = int(len / 2)

	if len % 2 == 0:   # Even.
		for index in range(half):
			# Left one.
			number_instances[len - index - 1].set_pos(Vector2(-SPRITE_WIDTH * (1.5 - half), 0))
			# Right one.
			number_instances[index].set_pos(Vector2(SPRITE_WIDTH * (half - 0.5), 0))

	else:   # Odd.
		for index in range(half):
			# Left one.
			number_instances[len - index - 1].set_pos(Vector2(-SPRITE_WIDTH * half, 0))
			# Right one.
			number_instances[index].set_pos(Vector2(SPRITE_WIDTH * half, 0))

		# The middle one.
		number_instances[half].set_pos(Vector2(0, 0))

func add_numbers_as_children():
	for number in number_instances:
		add_child(number)

func _process(delta):
	timepassed += delta

	if timepassed >= SHOW_DURATION:
		queue_free()
		return

	# Position (floating up).
	set_global_pos(Vector2(start_pos.x, lerp(start_pos.y, start_pos.y + MOVEMENT_Y, timepassed / SHOW_DURATION)))

	# Alpha value.
	for number in number_instances:
		number.set_modulate(Color(color.r, color.g, color.b, lerp(1.0, 0.0, timepassed / SHOW_DURATION)))