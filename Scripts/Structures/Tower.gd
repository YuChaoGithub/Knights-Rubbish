extends Node2D

signal destroyed

export(int) var full_health = 1500
export(String, FILE) var collapsed_spawn_path_1 = "Null"
export(String, FILE) var collapsed_spawn_path_2 = "Null"
export(NodePath) var counter_for_spawned_mobs

const DANCE_INTERVAL_MIN = 5
const DANCE_INTERVAL_MAX = 9
const DANCE_ANIMATION_DURATION = 6
const COLLAPSE_ANIMATION_DURATION = 0.6

const BLINK_DURATION = 0.15
const BLINK_ALPHA = 0.5

var curr_health
var timer = null
var blink_timer = null
var collapsing = false

var cd_timer = preload("res://Scripts/Utils/CountdownTimer.gd")
var rng = preload("res://Scripts/Utils/RandomNumberGenerator.gd")

onready var bar = $"Health Bar/Inner"
onready var tower_sprite = $"Tower Sprite"
onready var animator = $"AnimationPlayer"

# Should be called by triggers to be activated.
func activate():
	curr_health = full_health
	
	movement_sequence()

func movement_sequence():
	animator.play("Dance")
	timer = cd_timer.new(rng.randi_range(DANCE_INTERVAL_MIN, DANCE_INTERVAL_MAX) + DANCE_ANIMATION_DURATION, self, "movement_sequence")

func update_health_bar():
	bar.scale = Vector2(1.0, float(curr_health) / float(full_health))

func collapsed():
	emit_signal("destroyed")

	$"Damage Area/Damage Area".remove_from_group("enemy")

	animator.play("Collapse")


	var mob_counter = get_node(counter_for_spawned_mobs)

	# HARD CODING, YEAH!
	if collapsed_spawn_path_1 != "Null":
		var new_mob = load(collapsed_spawn_path_1).instance()
		$"..".add_child(new_mob)
		new_mob.global_position = $"Collapse Spawn Pos 1".global_position
		new_mob.connect("defeated", mob_counter, "increment_count")

	if collapsed_spawn_path_2 != "Null":
		var new_mob = load(collapsed_spawn_path_2).instance()
		$"..".add_child(new_mob)
		new_mob.global_position = $"Collapse Spawn Pos 2".global_position
		new_mob.connect("defeated", mob_counter, "increment_count")

	timer.destroy_timer()
	timer = cd_timer.new(COLLAPSE_ANIMATION_DURATION, self, "queue_free")

func damaged(val):
	if collapsing:
		return

	curr_health = max(0, curr_health - val)
	update_health_bar()

	if curr_health == 0:
		collapsing = true
		collapsed()
	else:
		blink()

func blink():
	if blink_timer != null:
		blink_timer.destroy_timer()

	tower_sprite.modulate.a = BLINK_ALPHA

	blink_timer = cd_timer.new(BLINK_DURATION, self, "cancel_blink")

func cancel_blink():
	blink_timer = null
	tower_sprite.modulate.a = 1.0

func stunned(duration):
	pass

func slowed(multiplier, duration):
	pass

func knocked_back(vel_x, vel_y, x_fade_rate):
	pass

func healed(val):
	pass