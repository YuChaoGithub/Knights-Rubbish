extends Node2D

const MOVEMENT_Y = -100
const TEXT_SHOW_DURATION = 1.3
const NUMBER_SHOW_DURATION = 0.4
const SPRITE_WIDTH = 75

enum { STUNNED = -1, IMMUNE = -2, DEFENSE = -3, ATTACK = -4, SPEED = -5 }

var show_duration

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
var defense_scene = preload("res://Scenes/Utils/Numbers/Defense.tscn")
var attack_scene = preload("res://Scenes/Utils/Numbers/Attack.tscn")
var speed_scene = preload("res://Scenes/Utils/Numbers/Speed.tscn")

var number_instances = []
var timepassed = 0.0
var color
var parent

onready var start_pos = self.global_position

# Pass in -1 to show "Stunned!".
func initialize(number, color, pos, node):
	self.color = color

	parent = node.get_tree().get_root().get_node("Game Level")
	 
	global_position = pos.get_curr_pos(self)

	show_duration = TEXT_SHOW_DURATION

	if number == STUNNED:
		number_instances.push_back(stunned_scene.instance())
	elif number == IMMUNE || number == 0:
		number_instances.push_back(immune_scene.instance())
	elif number == DEFENSE:
		number_instances.push_back(defense_scene.instance())
	elif number == ATTACK:
		number_instances.push_back(attack_scene.instance())
	elif number == SPEED:
		number_instances.push_back(speed_scene.instance())
	else:
		show_duration = NUMBER_SHOW_DURATION
		instance_numbers(number)		
	
	settle_positions()
	add_numbers_as_children()

	parent.add_child(self)

func instance_numbers(number):
	# Only 3 digits are allowed.
	if number > 999:
		number = 999

	while number > 0:
		var new_num = number_scenes[int(number) % 10].instance()
		number_instances.push_back(new_num)
		number = int(number / 10)

func settle_positions():
	var num_len = number_instances.size()
	var half = int(num_len / 2)

	if num_len % 2 == 0:   # Even.
		for index in range(half):
			# Left one.
			number_instances[num_len - index - 1].position = Vector2(-SPRITE_WIDTH * (1.5 - half), 0)
			# Right one.
			number_instances[index].position = Vector2(SPRITE_WIDTH * (half - 0.5), 0)

	else:   # Odd.
		for index in range(half):
			# Left one.
			number_instances[num_len - index - 1].position = Vector2(-SPRITE_WIDTH * half, 0)
			# Right one.
			number_instances[index].position = Vector2(SPRITE_WIDTH * half, 0)

		# The middle one.
		number_instances[half].position = Vector2(0, 0)

func add_numbers_as_children():
	for number in number_instances:
		add_child(number)

func _process(delta):
	timepassed += delta

	if timepassed >= show_duration:
		queue_free()
		return

	# Position (floating up).
	global_position = Vector2(start_pos.x, lerp(start_pos.y, start_pos.y + MOVEMENT_Y, timepassed / show_duration))

	# Alpha value.
	for number in number_instances:
		number.self_modulate = Color(color.r, color.g, color.b, lerp(1.0, 0.0, timepassed / show_duration))