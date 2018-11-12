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

signal defeated

enum { NONE, IDLE, INPUT, PROCESS, OUTPUT, SHOOT }

export(int) var activate_range_x = 1500
export(int) var activate_range_y = 1500

const MAX_HEALTH = 2500

# Touch Damage.
const TOUCH_DAMAGE = 10
const KNOCK_BACK_VEL_X = 1000
const KNOCK_BACK_VEL_Y = 1000
const KNOCK_BACK_FADE_RATE = 1000

# Text Damage.
const SLOW_RATE = 0.5
const SLOW_DURATION = 4.0
const CONFUSION_DURATION = 3.0
const ORDINARY_DAMAGE = 10
const FIRE_DAMAGE_PER_TICK = 10
const FIRE_TIME_PER_TICK = 1.0
const FIRE_TOTAL_TICKS = 4
const HURT_DAMAGE = 60
const STUN_DURATION = 5.0

# Animation.
const IDLE_ANIMATION_MIN_DURATION = 3.0
const IDLE_ANIMATION_MAX_DURATION = 5.0
const DIE_ANIMATION_DURATION = 5.0
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
onready var input_ball_sounds = {
	confuse = preload("res://Audio/latortrans_en_confusion.wav"),
	slow = preload("res://Audio/latortrans_en_slow.wav"),
	fire = preload("res://Audio/latortrans_en_fire.wav"),
	stun = preload("res://Audio/latortrans_en_stun.wav"),
	hurt = preload("res://Audio/latortrans_en_hurt.wav")
}
onready var output_ball_sounds = {
	confuse = preload("res://Audio/latortrans_ch_confusion.wav"),
	slow = preload("res://Audio/latortrans_ch_slow.wav"),
	fire = preload("res://Audio/latortrans_ch_fire.wav"),
	stun = preload("res://Audio/latortrans_ch_stun.wav"),
	hurt = preload("res://Audio/latortrans_ch_hurt.wav")
}
onready var ball_spawn_pos = $"Output Pos"
onready var spawn_node = $".."

var ball_directions = [Vector2(-1, 0), Vector2(-0.87, 0.5), Vector2(-0.5, 0.87), Vector2(0, 1)]

var status_timer = null
var idle_timer = null
var die_timer = null

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)

onready var left_audio_source = $Audio/LeftTube
onready var right_audio_source = $Audio/RightTube
onready var processing_audio = $Audio/Processing

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
		input_words[key].visible = false

	input_words[curr_attack].visible = true

	right_audio_source.stream = input_ball_sounds[curr_attack]
	right_audio_source.play()

	ec.play_animation("Input")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(INPUT_ANIMATION_DURATION, self, "change_status", PROCESS)

func play_process_anim():
	ec.play_animation("Processing")
	processing_audio.play()
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(PROCESS_ANIMATION_DURATION, self, "change_status", OUTPUT)

func play_output_anim():
	ec.play_animation("Output")
	processing_audio.stop()
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(OUTPUT_ANIMATION_FIRST_DURATION, self, "change_status", SHOOT)

func shoot_ball():
	ec.change_status(NONE)

	left_audio_source.stream = output_ball_sounds[curr_attack]
	left_audio_source.play()

	for dir in ball_directions:
		var new_ball = output_balls[curr_attack].instance()
		new_ball.initialize(dir)
		spawn_node.add_child(new_ball)
		new_ball.global_position = ball_spawn_pos.global_position

	status_timer = ec.cd_timer.new(OUTPUT_ANIMATION_SECOND_DURATION, self, "change_status", IDLE)

func touch_damage_hit(area):
	if area.is_in_group("hero"):
		var hero = area.get_node("..")
		var dir = sign(hero.global_position.x - global_position.x)
		hero.knocked_back(dir * KNOCK_BACK_VEL_X, KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)
		hero.damaged(TOUCH_DAMAGE)

func input_attack_hit(area):
	if area.is_in_group("hero"):
		var hero = area.get_node("..")
		match curr_attack:
			"confuse":
				hero.confused(CONFUSION_DURATION)
				hero.damaged(ORDINARY_DAMAGE)
			"slow":
				var args = {
					multiplier = SLOW_RATE,
					duration = SLOW_DURATION
				}
				hero.speed_changed(args)
				hero.damaged(ORDINARY_DAMAGE)
			"fire":
				var dot = preload("res://Scenes/Utils/Change Health OT.tscn").instance()
				hero.add_child(dot)
				dot.initialize(-FIRE_DAMAGE_PER_TICK, FIRE_TIME_PER_TICK, FIRE_TOTAL_TICKS)
				hero.show_ignited_particles(FIRE_TIME_PER_TICK * FIRE_TOTAL_TICKS)
			"stun":
				hero.stunned(STUN_DURATION)
				hero.damaged(ORDINARY_DAMAGE)
			"hurt":
				hero.damaged(HURT_DAMAGE)

func damaged(val):
	ec.damaged(val, ec.animator.current_animation == "Idle")

func resume_from_damaged():
	ec.resume_from_damaged()

func stunned(duration):
	pass

func healed(val):
	ec.healed(val)

func knocked_back(vel_x, vel_y, fade_rate):
	return

func slowed(multiplier, duration):
	return

func die():
	processing_audio.stop()
	$TouchDamageArea.queue_free()
	$Animation/Body/Input/InputAttackArea.queue_free()

	var user_data = get_node("/root/UserDataSingleton")
	user_data.level_available.amazlet = 1
	user_data.save_level_data()

	ec.die()
	ec.health_bar.drop_health_bar()
	set_process(false)
	
	die_timer = ec.cd_timer.new(DIE_ANIMATION_DURATION, self, "emit_signal", "defeated")