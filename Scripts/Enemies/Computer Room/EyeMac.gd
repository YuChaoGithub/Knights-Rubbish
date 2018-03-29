extends Node2D

# 1. Randomly go to 2 of a, b, c, d.
# 2. Damage area appears.
# 3. Go to 1.
# ===
# a. Pump up Harddies.
# b. Plays music and spawn Plugobra.
# c. Drop usb bombs (2 times).
# d. Shoot mouse bullets.

enum { NONE, RNG_IDLE,
	   HEART_APPEAR, HEART, HEART_DISAPPEAR,
	   PUMP_UP_APPEAR, PUMP_UP_ANIM, PUMP,
	   MUSIC_APPEAR, PLAY_MUSIC, MUSIC_DISAPPEAR,
	   DROP_APPEAR, DROP,
	   SHOOT_APPEAR, SHOOT, SHOOT_DISAPPEAR }

export(int) var activate_range_x = 1000
export(int) var activate_range_y = 1500

const MAX_HEALTH = 2000

# Attack.
const CONSECUTIVE_ATTACK_COUNT = 2
const ATTACK_MOVES = [PUMP_UP_APPEAR, MUSIC_APPEAR, DROP_APPEAR, SHOOT_APPEAR]
const USB_DROP_COUNT = 2
const SHOOT_ROTATE_SPEED = 52
const MOUSE_BULLET_COUNT = 12

# Animation.
const RNG_IDLE_DURATION = 1.0
const HEART_APPEAR_DURATION = 1.0
const HEART_DISAPPEAR_DURATION = 0.8
const HEART_MIN_DURATION = 5.0
const HEART_MAX_DURATION = 10.0
const MUSIC_APPEAR_DURATION = 0.5
const MUSIC_DURATION = 7.0
const MUSIC_DISAPPEAR_DURATION = 0.5
const PUMP_UP_APPEAR_DURATION = 1.5
const PUMP_UP_ANIM_DURATION = 1.55
const PUMP_UP_DURATION = 0.45
const DROP_APPEAR_DURATION = 2.0
const DROP_DURATION = 1.5
const SHOOT_APPEAR_DURATION = 0.5
const SHOOT_INTERVAL = 0.5
const SHOOT_DISAPPEAR_DURATION = 0.5

const EYEBALL_SPEED = 100

var status_timer = null
var attack_round = 0
var previous_attack = -1
var usb_bomb_count = 0
var shoot_mouse_index = 0
var mouse_bullet_timer = null
var eyed_character = null

onready var spawn_node = $".."

# Heart.
onready var hurt_heart = $"Animation/Screen/Hurt Me Screen/Heart"
onready var heart_left_pos_x = $"Animation/Screen/Hurt Me Screen/Left Pos".position.x
onready var heart_right_pos_x = $"Animation/Screen/Hurt Me Screen/Right Pos".position.x
onready var damage_area = $"Animation/Damage Area"

# Shoot Mouse.
var mouse = preload("res://Scenes/Enemies/Computer Room/Eye Mac Mouse.tscn")
onready var mouse_cannon = $"Animation/Screen/Shoot Mouse Screen/Cannon"
onready var mouse_spawn_pos = mouse_cannon.get_node("Spawn Pos")

# Pump Harddies.
var harddies = preload("res://Scenes/Enemies/Computer Room/Harddies.tscn")
onready var harddies_spawn_pos = $"Animation/Harddies Spawn Pos"

# Music.
var plugobra = preload("res://Scenes/Enemies/Computer Room/Plugobra.tscn")
onready var plugobra_spawn_poses = [
	$"Animation/Plugobra Spawn Poses/1",
	$"Animation/Plugobra Spawn Poses/2",
	$"Animation/Plugobra Spawn Poses/3",
	$"Animation/Plugobra Spawn Poses/4"
]

# USB Drop.
var usb_bomb = preload("res://Scenes/Enemies/Computer Room/Eye Mac USB Bomb.tscn")
onready var usb_bomb_frame = $"Animation/Screen/Drop USB Scene/Frame"
onready var usb_bomb_spawn_pos = usb_bomb_frame.get_node("Spawn Pos")
onready var usb_frame_bottom_left_pos = $"Animation/Screen/Drop USB Scene/Bottom Left"
onready var usb_frame_top_right_pos = $"Animation/Screen/Drop USB Scene/Top Right"

# Screen Crack.
var screen_crack_textures = [
	null,
	preload("res://Graphics/Enemies/Computer Room/Eyemac/Broken Screen 7.png"),
	preload("res://Graphics/Enemies/Computer Room/Eyemac/Broken Screen 6.png"),
	preload("res://Graphics/Enemies/Computer Room/Eyemac/Broken Screen 5.png"),
	preload("res://Graphics/Enemies/Computer Room/Eyemac/Broken Screen 4.png"),
	preload("res://Graphics/Enemies/Computer Room/Eyemac/Broken Screen 3.png"),
	preload("res://Graphics/Enemies/Computer Room/Eyemac/Broken Screen 2.png"),
	preload("res://Graphics/Enemies/Computer Room/Eyemac/Broken Screen 1.png")
]
onready var screen_crack = $"Animation/Screen/Broken Screen"

# Eyeball.
onready var eyeball = $"Animation/Screen/Eye/Eyeball"

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)

func activate():
	ec.health_bar.show_health_bar()
	set_process(true)
	ec.change_status(RNG_IDLE)

	eyed_character = ec.target_detect.get_nearest(self, ec.hero_average_pos.characters)

func _process(delta):
	if ec.not_hurt_dying_stunned():
		match ec.status:
			RNG_IDLE:
				rng_idle()
			HEART_APPEAR:
				heart_appear()
			HEART:
				heart()
			HEART_DISAPPEAR:
				heart_disappear()
			PUMP_UP_APPEAR:
				pump_up_appear()
			PUMP_UP_ANIM:
				pump_up_anim()
			PUMP:
				pump()
			MUSIC_APPEAR:
				music_appear()
			PLAY_MUSIC:
				play_music()
			MUSIC_DISAPPEAR:
				music_disappear()
			DROP_APPEAR:
				drop_appear()
			DROP:
				drop()
			SHOOT_APPEAR:
				shoot_appear()
			SHOOT:
				shoot(delta)
			SHOOT_DISAPPEAR:
				shoot_disappear()
	
	eyeball_follow_character(delta)

func eyeball_follow_character(delta):
	var direction = (eyed_character.global_position - eyeball.global_position).normalized()
	eyeball.move(direction * EYEBALL_SPEED * delta)

func change_status(to_status):
	ec.change_status(to_status)

func rng_idle():
	attack_round += 1
	
	var to_status
	if attack_round > CONSECUTIVE_ATTACK_COUNT:
		to_status = HEART_APPEAR
		attack_round = 0
	else:
		# Get an attack different from the previous one.
		var index = ec.rng.randi_range(0, ATTACK_MOVES.size())
		while ATTACK_MOVES[index] == previous_attack:
			index = ec.rng.randi_range(0, ATTACK_MOVES.size())

		to_status = ATTACK_MOVES[index]
		previous_attack = to_status
	
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(RNG_IDLE_DURATION, self, "change_status", to_status)

func heart_appear():
	# Determine the position of the heart.
	var pos_x = ec.rng.randf_range(heart_left_pos_x, heart_right_pos_x)
	hurt_heart.set_pos(Vector2(pos_x, hurt_heart.position.y))

	damage_area.add_to_group("enemy")

	ec.play_animation("Hurt Me Appear")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(HEART_APPEAR_DURATION, self, "change_status", HEART)

func heart():
	ec.play_animation("Hurt Me Screen")

	if status_timer == null:
		status_timer = ec.cd_timer.new(ec.rng.randf_range(HEART_MIN_DURATION, HEART_MAX_DURATION), self, "change_status", HEART_DISAPPEAR)

func heart_disappear():
	ec.play_animation("Hurt Me Disappear")
	ec.change_status(NONE)

	damage_area.remove_from_group("enemy")
	
	status_timer = ec.cd_timer.new(HEART_DISAPPEAR_DURATION, self, "change_status", RNG_IDLE)

func pump_up_appear():
	ec.play_animation("Pump Harddies Appear")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(PUMP_UP_APPEAR_DURATION, self, "change_status", PUMP_UP_ANIM)

func pump_up_anim():
	ec.play_animation("Pump Harddies Screen")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(PUMP_UP_ANIM_DURATION, self, "change_status", PUMP)

func pump():
	ec.change_status(NONE)

	var new_harddies = harddies.instance()
	spawn_node.add_child(new_harddies)
	new_harddies.global_position = harddies_spawn_pos.global_position

	status_timer = ec.cd_timer.new(PUMP_UP_DURATION, self, "change_status", RNG_IDLE)

func music_appear():
	ec.play_animation("Music Note Appear")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(MUSIC_APPEAR_DURATION, self, "change_status", PLAY_MUSIC)

func play_music():
	ec.play_animation("Music Note Screen")
	ec.change_status(NONE)

	var spawn_poses_x = []
	for index in range(0, plugobra_spawn_poses.size() - 1):
		spawn_poses_x.push_back(ec.rng.randf_range(plugobra_spawn_poses[index].global_position.x, plugobra_spawn_poses[index+1].global_position.x))

	for spawn_pos_x in spawn_poses_x:
		var new_plugobra = plugobra.instance()
		spawn_node.add_child(new_plugobra)
		new_plugobra.global_position = Vector2(spawn_pos_x, plugobra_spawn_poses[0].global_position.y)
	
	status_timer = ec.cd_timer.new(MUSIC_DURATION, self, "change_status", MUSIC_DISAPPEAR)

func music_disappear():
	ec.play_animation("Music Note Disappear")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(MUSIC_DISAPPEAR_DURATION, self, "change_status", RNG_IDLE)

func drop_appear():
	# Randomize the position of the Drop Frame.
	var pos_x = ec.rng.randf_range(usb_frame_bottom_left_pos.global_position.x, usb_frame_top_right_pos.global_position.x)
	var pos_y = ec.rng.randf_range(usb_frame_top_right_pos.global_position.y, usb_frame_bottom_left_pos.global_position.y)
	usb_bomb_frame.global_position = Vector2(pos_x, pos_y)

	ec.play_animation("USB Drop")
	ec.change_status(NONE)

	status_timer = ec.cd_timer.new(DROP_APPEAR_DURATION, self, "change_status", DROP)

func drop():
	var new_usb = usb_bomb.instance()
	spawn_node.add_child(new_usb)
	new_usb.global_position = usb_bomb_spawn_pos.global_position

	usb_bomb_count += 1

	var to_status = DROP_APPEAR
	if usb_bomb_count == USB_DROP_COUNT:
		to_status = RNG_IDLE
		usb_bomb_count = 0
	
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(DROP_DURATION, self, "change_status", to_status)

func shoot_appear():
	ec.play_animation("Shoot Mouse Appear")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(SHOOT_APPEAR_DURATION, self, "change_status", SHOOT)

func shoot(delta):
	ec.play_animation("Shoot Mouse Screen")
	
	mouse_cannon.rotation_degrees += SHOOT_ROTATE_SPEED * delta

	if mouse_bullet_timer == null:
		mouse_bullet_timer = ec.cd_timer.new(SHOOT_INTERVAL, self, "shoot_mouse_bullet", 0)

func shoot_mouse_bullet(count):
	if count < MOUSE_BULLET_COUNT:
		spawn_mouse_bullet(Vector2(cos(mouse_cannon.rotation), -sin(mouse_cannon.rotation)))
		mouse_bullet_timer = ec.cd_timer.new(SHOOT_INTERVAL, self, "shoot_mouse_bullet", count + 1)
	else:
		mouse_bullet_timer = null
		ec.change_status(SHOOT_DISAPPEAR)

func spawn_mouse_bullet(direction):
	var new_mouse = mouse.instance()
	new_mouse.initialize(direction)
	spawn_node.add_child(new_mouse)
	new_mouse.global_position = mouse_spawn_pos.global_position

func shoot_disappear():
	ec.play_animation("Shoot Mouse Disappear")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(SHOOT_DISAPPEAR_DURATION, self, "change_status", RNG_IDLE)

func damaged(val):
	ec.damaged(val, ec.status == HEART)

	crack_screen_according_to_health()

func crack_screen_according_to_health():
	var index = floor(float(ec.health_system.health) / float(MAX_HEALTH + 1) * screen_crack_textures.size())
	screen_crack.set_texture(screen_crack_textures[index])

func resume_from_damaged():
	ec.resume_from_damaged()

func stunned(duration):
	pass

func healed(val):
	ec.healed(val)

func die():
	ec.die()
	ec.health_bar.drop_health_bar()