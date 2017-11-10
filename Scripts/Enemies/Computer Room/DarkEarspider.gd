extends Node2D

# Dark Earspider AI:
# 1. Move horizontally to the place above a character (in bounds but farthest).
# 2. Drop down on the character's head.
# 3. Clap! (Stunning the character)
# 4. Spin dark silk to attack the character.
# 5. Move back up.
# 6. Repeat 1.

const MAX_HEALTH = 200
const ACTIVATE_RANGE = 750
const SPEED_X = 200
const SPEED_Y = 1000
const DROPPING_TO_CHAR_OFFSET_X = 200
const DROPPING_TO_CHAR_OFFSET_Y = 250
const DROP_DELAY = 1
const ATTACHED_SILK_THICKNESS = 5

enum { NONE, MOVE, DROP, CLAP, SPIN_SILK, CLIMB }

# It can only move between the bounds.
export(int) var left_bound
export(int) var right_bound

var status = NONE
var attack_target = null
var status_timer = null

var countdown_timer = preload("res://Scripts/Utils/CountdownTimer.gd")
var target_detection = preload("res://Scripts/Algorithms/TargetDetection.gd")

onready var original_pos = get_pos()
onready var silk_attach_spot = get_node("Animation/Body/Silk Pos")
onready var silk_attach_spot_original_pos = silk_attach_spot.get_global_pos()
onready var char_average_pos = get_node("../../../../Character Average Position")
onready var animator = get_node("Animation/AnimationPlayer")
onready var movement_type = preload("res://Scripts/Movements/StraightLineMovement.gd").new(0, 0)
onready var health_system = preload("res://Scripts/Utils/HealthSystem.gd").new(self, MAX_HEALTH)
onready var health_bar = get_node("Health Bar")
onready var number_spawn_pos = get_node("Number Spawn Pos")
onready var enemy_common = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self, ACTIVATE_RANGE, char_average_pos, animator, health_system, health_bar, number_spawn_pos, "Still")

func _ready():
	set_process(true)

func _process(delta):
	update()  # For _draw()
	if enemy_common.not_hurt_dying_stunned():
		if status == MOVE:
			move_horizontally_to_target(delta)
		elif status == DROP:
			drop_down(delta)
		elif status == CLAP:
			clap_attack()
		elif status == SPIN_SILK:
			spin_silk_attack()
		elif status == CLIMB:
			climb_up(delta)

func _draw():
	# Draw the attached black silk.
	var from_pos = silk_attach_spot.get_global_pos() - get_global_pos()
	var to_pos = Vector2(from_pos.x, from_pos.y - (silk_attach_spot.get_global_pos().y - silk_attach_spot_original_pos.y))
	draw_line(from_pos, to_pos, Color(0, 0, 0), ATTACHED_SILK_THICKNESS)

func change_status(to_status):
	status = to_status

func activate():
	# Find the farthest character as its attacking target.
	attack_target = target_detection.get_farthest(self, char_average_pos.characters)

	# Become damagable.
	get_node("Animation/Damage Area").add_to_group("enemy_collider")
	
	change_status(MOVE)

func move_horizontally_to_target(delta):
	var difference_x = attack_target.get_global_pos().x - get_global_pos().x

	# Apply horizontal movement.
	movement_type.dx = sign(difference_x) * SPEED_X
	movement_type.dy = 0
	var final_pos = movement_type.movement(get_pos(), delta)
	final_pos.x = clamp(final_pos.x, original_pos.x - left_bound, original_pos.x + left_bound)
	set_pos(final_pos)

	# Close enough, land after a delay.
	if abs(difference_x) <= DROPPING_TO_CHAR_OFFSET_X:
		change_status(NONE)
		status_timer = countdown_timer.new(DROP_DELAY, self, "change_status", DROP)

func drop_down(delta):
	movement_type.dy = SPEED_Y
	movement_type.dx = 0
	set_pos(movement_type.movement(get_pos(), delta))

	# Close enough, perform clap attack.
	if abs(get_global_pos().y - attack_target.get_global_pos().y) < DROPPING_TO_CHAR_OFFSET_Y:
		change_status(CLAP)

func clap_attack():
	print("CLAP")

func spin_silk_attack():
	pass

func climb_up(delta):
	pass

func damaged(val):
	pass

func resume_from_damaged():
	pass

func stunned(duration):
	pass

func resume_from_stunned():
	pass

func damaged_over_time(timer_per_tick, total_ticks, damage_per_tick):
	pass

func die():
	pass

func healed(val):
	pass

func healed_over_time(time_per_tick, total_tick, heal_per_tick):
	pass