extends Node2D

# Amazlet AI:
# 1. Show face. Speaks "I may be paranoid, but not an android."
# 2. 50% go to 3, 50% go to 5.
# 3. Spawns 1-4 Paranoid Android mob depending on its current HP.
# 4. Repeat 1.
# 5. Throws 2-5 HTC phone frizbee depending on its current HP.
# 6. Repeat 1.
# ===
# Only play hurt animation if it is in 1.
# Cannot be stunned.

signal defeated

export(int) var activate_range_x = 1000
export(int) var activate_range_y = 1000

enum { NONE, FACE, ANDROID_ANIM, SPAWN_ANDROID, FRIZBEE_ANIM, SPAWN_FRIZBEE, THROW_FRIZBEE, RESUME_FACE }

const MAX_HEALTH = 3500

# Attack.
const TOUCH_DAMAGE = 50
const KNOCK_BACK_VEL_X = 1000
const KNOCK_BACK_VEL_Y = 1000
const KNOCK_BACK_FADE_RATE = 1000
const ANDROID_MIN_SPAWN_COUNT = 1
const ANDROID_MAX_SPAWN_COUNT = 4
const FRIZBEE_MIN_SPAWN_COUNT = 2
const FRIZBEE_MAX_SPAWN_COUNT = 5

# Animation.
const FACE_ANIM_MAX_DURATION = 8
const FACE_ANIM_MIN_DURATION = 4
const ANDROID_ANIM_DURATION = 3.5
const ANDROID_SPAWNING_DURATION = 0.5
const FRIZBEE_ANIM_DURATION = 1.0
const FRIZBEE_SPAWNING_DURATION = 4.5
const FRIZBEE_THROWING_DURATION = 0.25
const RESUME_FACE_ANIM_DURATION = 0.5

var face_anim_timestamp = null
var face_anim_duration = null
var status_timer = null

var android_spawn_count
var frizbees = []

var paranoid_android = preload("res://Scenes/Enemies/Computer Room/Paranoid Android.tscn")
var frizbee = preload("res://Scenes/Enemies/Computer Room/Amazlet Frizbee.tscn")

onready var spawn_node = $".."
onready var android_spawn_pos = $"Android Spawn Pos"
onready var frizbee_spawn_pos = $"Frizbee Spawn Pos"

# Audio.
onready var spawn_android_audio = $"Audio/SpawnAndroid"
onready var toss_frizbee_audio = $"Audio/TossFrizbee"
onready var hurt_audio = $"Audio/Hurt"

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)

func activate():
	ec.health_bar.show_health_bar()
	set_process(true)
	ec.change_status(FACE)
	$"Animation/Damage Area".add_to_group("enemy")

func _process(delta):
	if ec.not_hurt_dying_stunned():
		match ec.status:
			FACE:
				show_face_and_play_voice()
			ANDROID_ANIM:
				play_android_anim()
			SPAWN_ANDROID:
				spawn_android()
			FRIZBEE_ANIM:
				play_frizbee_anim()
			SPAWN_FRIZBEE:
				spawn_frizbee()
			THROW_FRIZBEE:
				throw_frizbee()
			RESUME_FACE:
				resume_face()

func change_status(to_status):
	ec.change_status(to_status)

func show_face_and_play_voice():
	ec.play_animation("Face")

	if face_anim_timestamp == null:
		# TODO: Play "I may be paranoid..."
		face_anim_timestamp = OS.get_unix_time()
		face_anim_duration = ec.rng.randi_range(FACE_ANIM_MIN_DURATION, FACE_ANIM_MAX_DURATION + 1)
	elif OS.get_unix_time() - face_anim_timestamp >= face_anim_duration:
		# Goto either android or frizbee animation.
		if ec.rng.randsign() == 1:
			ec.change_status(ANDROID_ANIM)
		else:
			ec.change_status(FRIZBEE_ANIM)
		
		# Reset timestamp.
		face_anim_timestamp = null
		face_anim_duration = null

func play_android_anim():
	ec.play_animation("Spawn Android")
	ec.change_status(NONE)
	android_spawn_count = spawn_num_according_to_health(ANDROID_MIN_SPAWN_COUNT, ANDROID_MAX_SPAWN_COUNT)
	status_timer = ec.cd_timer.new(ANDROID_ANIM_DURATION, self, "change_status", SPAWN_ANDROID)

func spawn_android():
	# Spawn android.
	var new_android = paranoid_android.instance()
	spawn_node.add_child(new_android)
	new_android.global_position = android_spawn_pos.global_position

	spawn_android_audio.play()

	# Keep on spawning or go back to face.
	ec.change_status(NONE)
	android_spawn_count -= 1
	var to_status = RESUME_FACE if android_spawn_count == 0 else SPAWN_ANDROID
	status_timer = ec.cd_timer.new(ANDROID_SPAWNING_DURATION, self, "change_status", to_status)

func play_frizbee_anim():
	ec.play_animation("Throw Frizbee")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(FRIZBEE_ANIM_DURATION, self, "change_status", SPAWN_FRIZBEE)

func spawn_frizbee():
	var count = spawn_num_according_to_health(FRIZBEE_MIN_SPAWN_COUNT, FRIZBEE_MAX_SPAWN_COUNT)
	for i in range(count):
		var new_frizbee = frizbee.instance()
		spawn_node.add_child(new_frizbee)
		new_frizbee.global_position = frizbee_spawn_pos.global_position
		frizbees.push_back(new_frizbee)

	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(FRIZBEE_SPAWNING_DURATION, self, "change_status", THROW_FRIZBEE)

func throw_frizbee():
	frizbees.back().start_travel()
	frizbees.pop_back()
	toss_frizbee_audio.play()

	var to_status = RESUME_FACE if frizbees.size() == 0 else THROW_FRIZBEE
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(FRIZBEE_THROWING_DURATION, self, "change_status", to_status)

func resume_face():
	ec.play_animation("Face Coming Back")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(RESUME_FACE_ANIM_DURATION, self, "change_status", FACE)

func spawn_num_according_to_health(min_count, max_count):
	return int(lerp(float(min_count), float(max_count), 1.0 - (float(ec.health_system.health) / float(ec.health_system.full_health))))

func touch_attack_hit(area):
	if area.is_in_group("hero"):
		var character = area.get_node("..")
		character.knocked_back(-KNOCK_BACK_VEL_X, KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)
		character.damaged(TOUCH_DAMAGE)

func damaged(val):
	# Only play hurt animation in FACE.
	ec.damaged(val, ec.status == FACE)

func resume_from_damaged():
	ec.resume_from_damaged()

func knocked_back(vel_x, vel_y, fade_rate):
	return

func slowed(multiplier, duration):
	return

func die():
	ec.die()
	ec.health_bar.drop_health_bar()

	var user_data = get_node("/root/UserDataSingleton")
	user_data.level_available.radiogugu = 1
	user_data.save_level_data()

	emit_signal("defeated")

	# Disable touch damage.
	$"Animation/Attack Area".queue_free()

	# Remove the frizbees (if any).
	for f in frizbees:
		f.queue_free()

func stunned(duration):
	pass

func healed(val):
	ec.healed(val)