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

export(int) var activate_range_x = 1500
export(int) var activate_range_y = 1500

const MAX_HEALTH = 2000

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
	confuse = $"Animation/Body/Input/Confusion",
	slow = $"Animation/Body/Input/Slow",
	fire = $"Animation/Body/Input/Fire",
	stun = $"Animation/Body/Input/Stun",
	hurt = $"Animation/Body/Input/Hurt"
}
onready var output_balls = {
	confuse = preload("res://Scenes/Enemies/Computer Room/Latortrans confusion ball.tscn"),
	slow = preload("res://Scenes/Enemies/Computer Room/Latortrans slow ball.tscn"),
	fire = preload("res://Scenes/Enemies/Computer Room/Latortrans fire ball.tscn"),
	stun = preload("res://Scenes/Enemies/Computer Room/Latortrans stun ball.tscn"),
	hurt = preload("res://Scenes/Enemies/Computer Room/Latortrans hurt ball.tscn")
}
onready var ball_spawn_pos = $"Output Pos"
onready var spawn_node = $".."

var ball_directions = [Vector2(-1, 0), Vector2(-0.87, 0.5), Vector2(-0.87, -0.5)]

var status_timer = null
var idle_timer = null

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)

func activate():
	ec.health_bar.show_health_bar()
	set_process(true)
	ec.change_status(IDLE)
	$"Animation/Damage Area".add_to_group("enemy")

func _process(delta):
	if ec.not_hurt_dying_stunned():
		match ec.status:
			IDLE:
				play_idle_anim()
			INPUT:
				play_input_anim()
			PROCESS:
				play_process_anim()
			OUTPUT:
				play_output_anim()
			SHOOT:
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
		new_ball.global_position = ball_spawn_pos.global_position

	status_timer = ec.cd_timer.new(OUTPUT_ANIMATION_SECOND_DURATION, self, "change_status", IDLE)

func damaged(val):
	ec.damaged(val, ec.animator.current_animation == "Idle")

func resume_from_damaged():
	ec.resume_from_damaged()

func stunned(duration):
	ec.display_immune_text()

func healed(val):
	ec.healed(val)

func knocked_back(vel_x, vel_y, fade_rate):
	return

func slowed(multiplier, duration):
	return

func die():
	ec.die()
	ec.health_bar.drop_health_bar()
	status_timer = ec.cd_timer.new(DIE_ANIMATION_DURATION, self, "queue_free")