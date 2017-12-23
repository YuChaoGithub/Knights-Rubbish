extends Node2D

# Latortrans AI:
# 1. Idle for some time.
# 2. English words marching in
# 3. Reads them out loud (Processing).
# 4. Chinese characters (bullets) coming out.
# 5. Repeat 1.
# ===
# Cannot be stunned.
# Play hurt animation only when idle.

enum { NONE, IDLE, INPUT, PROCESS, OUTPUT, SHOOT }

const MAX_HEALTH = 2000

const ACTIVATE_RANGE = 1500

# Animation.
const IDLE_ANIMATION_MIN_DURATION = 5.0
const IDLE_ANIMATION_MAX_DURATION = 8.0
const DIE_ANIMATION_DURATION = 0.5
const INPUT_ANIMATION_DURATION = 4.0
const OUTPUT_ANIMATION_FIRST_DURATION = 0.7
const OUTPUT_ANIMATION_SECOND_DURATION = 0.6
const PROCESS_ANIMATION_DURATION = 2.0

var attack_keys = ["confuse", "slow", "fire", "stun", "hurt"]
var curr_attack = null

onready var input_words = {
	confuse = get_node("Animation/Body/Input/Confusion"),
	slow = get_node("Animation/Body/Input/Slow"),
	fire = get_node("Animation/Body/Input/Fire"),
	stun = get_node("Animation/Body/Input/Stun"),
	hurt = get_node("Animation/Body/Input/Hurt")
}
onready var output_balls = {
	confuse = preload("res://Scenes/Enemies/Computer Room/Latortrans confusion ball.tscn"),
	slow = preload("res://Scenes/Enemies/Computer Room/Latortrans slow ball.tscn"),
	fire = preload("res://Scenes/Enemies/Computer Room/Latortrans fire ball.tscn"),
	stun = preload("res://Scenes/Enemies/Computer Room/Latortrans stun ball.tscn"),
	hurt = preload("res://Scenes/Enemies/Computer Room/Latortrans hurt ball.tscn")
}
onready var ball_spawn_pos = get_node("Output Pos")
onready var spawn_node = get_node("..")

var ball_directions = [Vector2(-1, 0), Vector2(-0.87, 0.5), Vector2(-0.87, -0.5)]

var status_timer = null
var idle_timer = null

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)

func activate():
	set_process(true)
	ec.change_status(IDLE)
	get_node("Animation/Damage Area").add_to_group("enemy_collider")

func _process(delta):
	if ec.not_hurt_dying_stunned():
		if ec.status == IDLE:
			play_idle_anim()
		elif ec.status == INPUT:
			play_input_anim()
		elif ec.status == PROCESS:
			play_process_anim()
		elif ec.status == OUTPUT:
			play_output_anim()
		elif ec.status == SHOOT:
			shoot_ball()

func change_status(to_status):
	ec.change_status(to_status)

func play_idle_anim():
	ec.play_animation("Idle")
	
	if idle_timer == null:
		idle_timer = ec.cd_timer.new(ec.rng.randf_range(IDLE_ANIMATION_MIN_DURATION, IDLE_ANIMATION_MAX_DURATION), self, "change_status", INPUT)

func play_input_anim():
	idle_timer = null

	curr_attack = attack_keys[ec.rng.randi_range(0, attack_keys.size())]
	
	# Hide all input words except the chosen one.
	for key in attack_keys:
		input_words[key].set_hidden(true)

	input_words[curr_attack].set_hidden(false)

	ec.play_animation("Input")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(INPUT_ANIMATION_DURATION, self, "change_status", PROCESS)

func play_process_anim():
	ec.play_animation("Processing")
	# TODO: Speak the translated word.
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(PROCESS_ANIMATION_DURATION, self, "change_status", OUTPUT)

func play_output_anim():
	ec.play_animation("Output")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(OUTPUT_ANIMATION_FIRST_DURATION, self, "change_status", SHOOT)

func shoot_ball():
	ec.change_status(NONE)

	for dir in ball_directions:
		var new_ball = output_balls[curr_attack].instance()
		new_ball.initialize(dir)
		spawn_node.add_child(new_ball)
		new_ball.set_global_pos(ball_spawn_pos.get_global_pos())

	status_timer = ec.cd_timer.new(OUTPUT_ANIMATION_SECOND_DURATION, self, "change_status", IDLE)

func damaged(val):
	ec.damaged(val, ec.animator.get_current_animation() == "Idle")

func resume_from_damaged():
	ec.resume_from_damaged()

func damaged_over_time(time_per_tick, total_ticks, damage_per_tick):
	ec.damaged_over_time(time_per_tick, total_ticks, damage_per_tick)

func stunned(duration):
	ec.display_immune_text()

func healed(val):
	ec.healed(val)

func healed_over_time(time_per_tick, total_ticks, heal_per_tick):
	ec.healed_over_time(time_per_tick, total_ticks, heal_per_tick)

func die():
	ec.die()

	status_timer = ec.cd_timer.new(DIE_ANIMATION_DURATION, self, "queue_free")