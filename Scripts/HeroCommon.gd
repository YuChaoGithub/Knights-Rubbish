extends KinematicBody2D

export(String, FILE) var player_constants_filepath
export(NodePath) var defense_icon_path
export(NodePath) var attack_icon_path
export(NodePath) var slowed_icon_path
export(NodePath) var speeded_icon_path
export(NodePath) var confused_icon_path

signal did_jump

# The amount of time (in seconds) to play idle animation.
const TIME_TO_IDLE_ANIMATION = 5

# Grabbing and dropping.
const GRABBING_DURATION = 1.0
const DROPPING_DURATION = 3.5
const FALL_OFF_DAMAGE = 100

const PORTAL_DURATION = 0.15

const DRINK_ANIMATION_DURATION = 1.5
const POWERUP_RECOVER_ANIMATION_DURATION = 3.0
const ABNORMAL_RECOVER_ANIMATION_DURATION = 0.5
const SIZE_CHANGE_DURATION = 0.5
const DIE_ANIMATION_DURATION = 2.0

# The actual damage taken will be 20% less or more randomly.
const DAMAGE_TAKEN_RAND_RATIO = 0.2

const HURT_MODULATE_DURATION = 0.15
const DAMAGE_NUMBER_COLOR = Color(255.0 / 255.0, 0.0 / 255.0, 210.0 / 255.0)
const GHOST_DAMAGE_NUMBER_COLOR = Color(0.0, 0.0, 0.0)
const HEAL_NUMBER_COLOR = Color(110.0 / 255.0, 240.0 / 255.0, 15.0 / 255.0)
const STUNNED_TEXT_COLOR = Color(180.0 / 255.0, 180.0 / 255.0, 0.0 / 255.0)
const IMMUNE_TEXT_COLOR = Color(255.0 / 255.0, 230.0 / 255.0, 0.0 / 255.0)
const DEFENSE_TEXT_COLOR = Color(60.0 / 255.0, 227.0 / 255.0, 255.0 / 255.0)
const ATTACK_TEXT_COLOR = Color(255.0 / 255.0, 50.0 / 255.0, 0.0 / 255.0)
const SPEED_TEXT_COLOR = Color(0.0 / 255.0, 200.0 / 255.0, 255.0 / 255.0)

# p1: 0, p2: 1
var player_index

# Controls the basic animations (walk, jump, idle, etc.) of characters.
# The name of the default animator is defined in player_constants.
# Loaded in _ready().
var animator

# Record the time which the player is idle.
var idle_timestamp

# Calculated values, so that movement could be done more conveniently.
var gravity
var jump_speed
var speed

# State modifier (could be changed by power ups, debuffs, or skill).
var movement_speed_modifier = 1.0
var attack_modifier = 1.0
var defense_modifier = 1.0
var self_knock_back_modifier = 1.0
var enemy_knock_back_modifier = 1.0

var side setget ,get_side
var size setget ,get_size

# For knockback or movement skills.
var additional_speed_x = 0
var additional_speed_x_fading_rate = 0

# Velocity replacement for verticle movement skills (note that the velocity would only be replaced once).
var velocity_replacement_y = null

# Current velocity of the character.
var velocity = Vector2(0, 0)

# The status of the character commonly used by timers.
# A {tag:String -> Bool} dictionary.
var status = {
	can_move = true,
	can_jump = true,
	can_cast_skill = true,
	animate_movement = true,
	invincible = false,
	no_movement = false,
	confused = false,
	has_ult = false,
	fallen_off = false,
	cc_immune = false,
	dead = false,
	drinking = false
}

# Being set by HeroManager.
# A dictionary of key binding strings:
# The keys are: up, down, left, right, skill, attack, jump, ult.
var action_strings

enum { DWARF = 0, NORMAL = 1, GIANT = 2 }
var size_status = NORMAL
var size_multipliers = [
	{size = 0.5, attack = 0.75, defense = 1.2,  self_knock_back = 1.5, enemy_knock_back = 0.5},
	{size = 1.0, attack = 1.0,  defense = 1.0,  self_knock_back = 1.0, enemy_knock_back = 1.0},
	{size = 1.5, attack = 1.5,  defense = 0.75, self_knock_back = 0.5, enemy_knock_back = 2.0}
]

var countdown_timer = preload("res://Scripts/Utils/CountdownTimer.gd")
var opacity_lerper = preload("res://Scenes/Utils/Parent Opacity Lerper.tscn")
var rng = preload("res://Scripts/Utils/RandomNumberGenerator.gd")

# Active timers for power ups.
# For cancelling timers for conflicting power ups/state changes.
# The data should be saved as dictionaries {tag:String -> CountdownTimer}.
# tags: "status", ignite, defense_change, attack_change, giant_dwarf_potion, confused.
var active_timers = {}

var speed_timers = {} # Label -> {timer, multiplier}
var die_timer
var speed_timer_label = 0
var slowed_count = 0
var speeded_count = 0
var hurt_modulate_timer = null
var fall_off_timer = null
var drink_timer
var size_tween
var top_fist = null
var ghost_health

var lightning = preload("res://Scenes/Effects/Lightning.tscn")

onready var hero_layer = ProjectSettings.get_setting("layer_names/2d_physics/hero")

onready var combo_handler = $"Combo Handler"

# Camera. For clamping within view bounds.
onready var following_camera = $"../FollowingCamera"

# Character stats.
onready var player_constants = load(player_constants_filepath)

# Manages healing, damaging, dying.
onready var health_system = preload("res://Scripts/Utils/HealthSystem.gd").new(self, player_constants.full_health)

# Particles.
onready var fire_particle = get_node(player_constants.fire_particle_node_path)
onready var ult_eyes = get_node(player_constants.ult_eyes_node_path)

# Damage, heal numbers indicator.
var number_indicator = preload("res://Scenes/Utils/Numbers/Number Indicator.tscn")
onready var number_spawn_pos = $"Number Spawn Pos"

onready var drink_sprite = $"Sprite/Animation/Drink"

onready var door_check_area = $DoorCheckArea
onready var health_bar = $"Health Bar"
onready var ghost_hit_box = $GhostHitBox
onready var sprite = $Sprite

onready var status_icons = {
	defense = get_node(defense_icon_path),
	attack = get_node(attack_icon_path),
	slowed = get_node(slowed_icon_path),
	confused = get_node(confused_icon_path),
	speeded = get_node(speeded_icon_path)
}

func _ready():
	# Configure movement related variables.
	recalculate_horizontal_movement_variables()
	recalculate_vertical_movement_variables()
	
	# Default animator.
	animator = get_node(player_constants.default_animator_path)

	# Hide all status icons.
	for icon in status_icons:
		status_icons[icon].visible = false

	# Hide all particles.
	fire_particle.visible = false

	# Initialize timestamp.
	idle_timestamp = OS.get_unix_time()

	# Health bar.
	health_bar.initialize(player_constants.full_health, player_constants.ghost_health, player_constants.avatar)
	health_bar.set_health_bar_position(player_index)

func _process(delta):
	check_combo_and_perform()

func _physics_process(delta):
	update_movement(delta)

# Move by keyboard inputs. Also play movement animations.
# Calculate the movement and pass it to Collision Handler. Set the position as the returned value and update the camera.
func update_movement(delta):
	if status.no_movement:
		move_and_slide(Vector2(0, 0), Vector2(0, -1))
		return

	# The movement animation name (key) supposed to be played.
	var animation_key = null

	# Play the "Still" animation if the player is currently landed on the ground.
	# Else, play the "Jump" animation (when in air).
	if is_on_floor():
		animation_key = "Still"
	else:
		animation_key = "Jump"

	# If hit above or hit below, reset velocity.
	if is_on_ceiling() or is_on_floor():
		velocity.y = 0
	
	var horizontal_movement = 0
	
	if status.can_move:
		# Horizontal keyboard input.
		if Input.is_action_pressed(action_strings.left):
			horizontal_movement += (1 if status.confused else -1)
		if Input.is_action_pressed(action_strings.right):
			horizontal_movement += (-1 if status.confused else 1)

		# In fist.
		if top_fist != null:
			top_fist.perform_movement(horizontal_movement, delta)

			var final_pos = top_fist.get_drop_pos()
			global_position = final_pos
			return
 
		# Override the "Still" animation if the character is walking (on the ground).
		if horizontal_movement != 0 && is_on_floor():
			animation_key = "Walk"
			
		# Jumping.
		if Input.is_action_pressed(action_strings.jump) && is_on_floor():
			velocity.y += jump_speed
			
			# Triggers events when jumping.
			emit_signal("did_jump")
	
	# Change the x scale of the sprite according to which side the character is facing.
	if horizontal_movement != 0 and sign(sprite.scale.x) != horizontal_movement:
		sprite.scale.x *= -1

	# Apply vertical velocity modifier if there is one.
	if velocity_replacement_y != null:
		velocity.y = velocity_replacement_y

		# Only apply this velocity once.
		velocity_replacement_y = null
	
	# Reduce additional speed x.
	additional_speed_x = sign(additional_speed_x) * max(0, abs(additional_speed_x) - abs(delta * additional_speed_x_fading_rate))

	velocity.x = horizontal_movement * speed + additional_speed_x
	velocity.y += gravity * delta

	move_and_slide(velocity, Vector2(0, -1))

	# Pass to the following camera, so that the character won't go beyond the camera.
	var camera_clamped_pos = following_camera.clamp_pos_within_cam_bounds(global_position)
	
	# Fall off check.
	if !status.fallen_off && camera_clamped_pos.y < global_position.y:
		falls_off()

	# Update the position of the character.
	global_position = camera_clamped_pos

	# Play the movement animation if no skill animation is currently being played.
	if status.animate_movement && animation_key != null && !status.dead:

		# Play idle animation if the character waits for too long.
		if animation_key == "Still" && OS.get_unix_time() - idle_timestamp >= TIME_TO_IDLE_ANIMATION:
			play_animation("Idle")
		else:
			play_animation(animation_key)

# Falls off the bottom of the screen.
func falls_off():
	status.fallen_off = true

	following_camera.cam_lock_semaphore += 1

	combo_handler.cancel_all_skills()
	interrupt_skills()

	visible = false
	following_camera.instance_bottom_grab(global_position.x)

	set_status("can_move", false, GRABBING_DURATION)
	set_status("can_cast_skill", false, GRABBING_DURATION + DROPPING_DURATION)
	set_status("no_movement", true, GRABBING_DURATION)
	set_status("can_jump", false, GRABBING_DURATION + DROPPING_DURATION)
	set_status("invincible", true, GRABBING_DURATION + DROPPING_DURATION)

	$"Damage Area".set_collision_layer_bit(hero_layer, false)

	fall_off_timer = countdown_timer.new(GRABBING_DURATION, self, "show_fist")

func show_fist():
	top_fist = following_camera.instance_top_fist(player_constants.avatar)
	
	fall_off_timer = countdown_timer.new(DROPPING_DURATION, self, "drop_from_fist")

func drop_from_fist():
	status.fallen_off = false

	if !status.dead:
		damaged(FALL_OFF_DAMAGE, false)

	velocity = Vector2(0.0, 0.0)

	following_camera.cam_lock_semaphore -= 1

	top_fist.release()
	
	var original_z = z_index
	z_index = top_fist.z_index + 1
	visible = true

	top_fist = null
	fall_off_timer = countdown_timer.new(0.5, self, "reset_z_index", original_z)

	$"Damage Area".set_collision_layer_bit(hero_layer, true)

func reset_z_index(original_z):
	z_index = original_z

# Perform combo by its function name.
func check_combo_and_perform():
	if status.dead:
		return

	if Input.is_action_pressed(action_strings.ult):
		# Ult.
		combo_handler.ult()
	elif Input.is_action_pressed(action_strings.skill):
		# Skills.
		if Input.is_action_pressed(action_strings.left):
			combo_handler.horizontal_skill(-1)
		elif Input.is_action_pressed(action_strings.right):
			combo_handler.horizontal_skill(1)
		elif Input.is_action_pressed(action_strings.up):
			combo_handler.up_skill()
		elif Input.is_action_pressed(action_strings.down):
			combo_handler.down_skill()
		else:
			combo_handler.basic_skill()
	elif Input.is_action_pressed(action_strings.attack):
		# Attack.
		combo_handler.basic_attack()
	elif Input.is_action_pressed(action_strings.up):
		check_door_to_enter()

func check_door_to_enter():
	if !status.can_move || status.dead:
		return

	var areas = door_check_area.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("door"):
			area.get_node("../..").hero_enter(self)
			return

func gain_ult():
	status.has_ult = true
	health_bar.change_to_ult_theme()
	ult_eyes.visible = true

	for eye_path in player_constants.eyes_node_path:
		get_node(eye_path).visible = false

func release_ult():
	status.has_ult = false
	health_bar.change_to_ordinary_theme()
	ult_eyes.visible = false

	for eye_path in player_constants.eyes_node_path:
		get_node(eye_path).visible = true

# Configure movement related variables.
func recalculate_horizontal_movement_variables():
	speed = player_constants.movement_speed * movement_speed_modifier
	
func recalculate_vertical_movement_variables():
	gravity = 2 * player_constants.jump_height / pow(player_constants.time_to_jump_to_highest, 2)
	jump_speed = -gravity * player_constants.time_to_jump_to_highest
	
# Manage the timer according to its tag.
# If conflicting timers are found. Stop the previous one and register the new one.
func register_timer(tag, timer):
	if tag in active_timers:
		# Stop the conflicting timer.
		active_timers[tag].time_out()
		
	# Register the new timer.
	active_timers[tag] = timer
	
# Unregister the timer when the timer ends.
func unregister_timer(tag):
	active_timers.erase(tag)

func timeout_timer_if_exist(tag):
	if tag in active_timers:
		active_timers[tag].time_out()
	unregister_timer(tag)

# Play the animation if it isn't played currently.
func play_animation(key):
	# Rest idle timer if the animation currently played isn't idle itself.
	if key != "Idle" && key != "Still":
		idle_timestamp = OS.get_unix_time()

	if animator.current_animation != key:
		animator.play(key)

# Register and unregister common timers for character states.
func set_status(status_tag, boolean, duration):
	register_timer(status_tag, countdown_timer.new(duration, self, "reset_status", [status_tag, not boolean]))
	status[status_tag] = boolean

# The arguments are [status_tag, boolean]
func reset_status(args):
	status[args[0]] = args[1]
	unregister_timer(args[0])

# Change the facing of the sprite. (1: right, -1: left)
func change_sprite_facing(side):
	sprite.scale.x = abs(sprite.scale.x) * side

func display_immune_text():
	var immune_text = number_indicator.instance()
	immune_text.initialize(-2, IMMUNE_TEXT_COLOR, number_spawn_pos, self)

func show_ignited_particles(duration):
	var ignite_timer = countdown_timer.new(duration, self, "ignited_recover")
	register_timer("ignite", ignite_timer)

	fire_particle.visible = true

func ignited_recover():
	unregister_timer("ignite")
	fire_particle.visible = false

func drink_potion(potion_sprite, end_func, args):
	interrupt_skills()
	combo_handler.cancel_all_skills()
	
	set_status("animate_movement", false, DRINK_ANIMATION_DURATION)
	set_status("can_move", false, DRINK_ANIMATION_DURATION)
	set_status("drinking", true, DRINK_ANIMATION_DURATION)
	
	drink_sprite.texture = potion_sprite
	
	play_animation("Drink")

	drink_timer = countdown_timer.new(DRINK_ANIMATION_DURATION, self, end_func, args)

# Common abnormal status. Func call sequence: original_func() -> original_func_blink() -> original_func_recover()
# args: {multiplier: _, duration: _}
func defense_boosted(args):
	timeout_timer_if_exist("defense_boost_recover")

	var defense_timer = countdown_timer.new(args.duration, self, "defense_boost_blink", args.multiplier)
	register_timer("defense_boost", defense_timer)

	defense_modifier *= args.multiplier

	number_indicator.instance().initialize(-3, DEFENSE_TEXT_COLOR, number_spawn_pos, self)

	status_icons.defense.visible = true
	status_icons.defense.get_node("AnimationPlayer").play("Pop")

func defense_boost_blink(multiplier):
	var defense_recovering_timer = countdown_timer.new(POWERUP_RECOVER_ANIMATION_DURATION, self, "defense_boost_recover", multiplier)
	register_timer("defense_boost_recover", defense_recovering_timer)

	status_icons.defense.get_node("AnimationPlayer").play("Blink")

	unregister_timer("defense_boost")

func defense_boost_recover(multiplier):
	defense_modifier /= multiplier
	status_icons.defense.visible = false
	unregister_timer("defense_boost_recover")

# args: {multiplier: _, duration: _}
func attack_boosted(args):
	timeout_timer_if_exist("attack_boost_recover")

	var attack_timer = countdown_timer.new(args.duration, self, "attack_boost_blink", args.multiplier)
	register_timer("attack_boost", attack_timer)

	number_indicator.instance().initialize(-4, ATTACK_TEXT_COLOR, number_spawn_pos, self)

	attack_modifier *= args.multiplier

	status_icons.attack.visible = true
	status_icons.attack.get_node("AnimationPlayer").play("Pop")

func attack_boost_blink(multiplier):
	var attack_recovering_timer = countdown_timer.new(POWERUP_RECOVER_ANIMATION_DURATION, self, "attack_boost_recover", multiplier)
	register_timer("attack_boost_recover", attack_recovering_timer)

	status_icons.attack.get_node("AnimationPlayer").play("Blink")

	unregister_timer("attack_boost")

func attack_boost_recover(multiplier):
	attack_modifier /= multiplier
	status_icons.attack.visible = false
	unregister_timer("attack_boost_recover")

# args: {multipliers: {_}, duration:_}
func dwarfed_or_gianted(type):
	if size_status != NORMAL && type == NORMAL:
		change_to_size(NORMAL)
	else:
		change_to_size(type)

func change_to_size(type):
	divided_by_multipliers(size_status)
	multiplied_by_multipliers(type)
	start_size_tween(size_multipliers[type].size)
	size_status = type

func multiplied_by_multipliers(index):
	var m = size_multipliers[index]
	defense_modifier *= m.defense
	attack_modifier *= m.attack
	self_knock_back_modifier *= m.self_knock_back
	enemy_knock_back_modifier *= m.enemy_knock_back

func divided_by_multipliers(index):
	var m = size_multipliers[index]
	defense_modifier /= m.defense
	attack_modifier /= m.attack
	self_knock_back_modifier /= m.self_knock_back
	enemy_knock_back_modifier /= m.enemy_knock_back

func start_size_tween(multiplier):
	# Terminate the previous tween.
	if size_tween != null:
		size_tween_completed(null, "")
	
	set_status("animate_movement", false, SIZE_CHANGE_DURATION)
	set_status("can_move", false, SIZE_CHANGE_DURATION)
	
	# Don't animate when dead.
	if !status.dead:
		play_animation("Size Change")

	size_tween = Tween.new()
	add_child(size_tween)
	size_tween.connect("tween_completed", self, "size_tween_completed")
	size_tween.interpolate_method(self, "size_tween_step", scale.x, multiplier, SIZE_CHANGE_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
	size_tween.start()

func size_tween_step(progress):	
	scale = Vector2(1.0, 1.0) * progress

func size_tween_completed(object, key):
	size_tween.queue_free()
	size_tween = null

# args: {multiplier:_, duration:_}
func speed_changed(args):
	# Cannot be slowed while invincible.
	if status.invincible && args.multiplier < 1.0:
		return

	movement_speed_modifier *= args.multiplier
	recalculate_horizontal_movement_variables()

	var speed_timer = countdown_timer.new(args.duration, self, "speed_change_recover", speed_timer_label)

	if args.multiplier < 1:
		status_icons.slowed.visible = true
		status_icons.slowed.get_node("AnimationPlayer").play("Pop")
		slowed_count += 1
	else:
		number_indicator.instance().initialize(-5, SPEED_TEXT_COLOR, number_spawn_pos, self)
		status_icons.speeded.visible = true
		speeded_count += 1

	speed_timers[speed_timer_label] = {
		timer = speed_timer,
		multiplier = args.multiplier
	}
	speed_timer_label += 1

func speed_change_recover(label):
	var speed_data = speed_timers[label]
	movement_speed_modifier /= speed_data.multiplier
	recalculate_horizontal_movement_variables()
	
	if speed_data.multiplier < 1:
		slowed_count -= 1
		if slowed_count == 0:
			status_icons.slowed.visible = false
	else:
		speeded_count -= 1
		if speeded_count == 0:
			status_icons.speeded.visible = false

	speed_timers.erase(label)

func stunned(duration):
	# Can't be stunned while invincible.
	if status.invincible || status.cc_immune || status.dead:
		return

	# Spawn stunned text.
	var stunned_text = number_indicator.instance()
	stunned_text.initialize(-1, STUNNED_TEXT_COLOR, number_spawn_pos, self)

	# Set status.
	set_status("can_move", false, duration)
	set_status("can_cast_skill", false, duration)
	set_status("can_jump", false, duration)
	set_status("animate_movement", false, duration)

	# Disable verticle inertia.
	velocity.y = 0

	# Timeout these timers.
	var timeout_tags = ["no_movement", "movement_skill"]
	for timeout_tag in timeout_tags:
		if active_timers.has(timeout_tag):
			active_timers[timeout_tag].time_out()
			# The key (in the dictionary) should be erased by the time_out() function call.

	interrupt_skills()
	play_animation("Stunned")

func interrupt_skills():
	if active_timers.has("interruptable_skill"):
		active_timers["interruptable_skill"].destroy_timer()
		active_timers.erase("interruptable_skill")

func confused(duration):
	if status.confused || status.invincible || status.cc_immune || status.dead:
		return

	status.confused = true

	status_icons.confused.visible = true
	status_icons.confused.get_node("AnimationPlayer").play("Pop")

	var confused_timer = countdown_timer.new(duration, self, "confused_blink")
	register_timer("confused", confused_timer)

func confused_blink():
	var confused_recovering_timer = countdown_timer.new(ABNORMAL_RECOVER_ANIMATION_DURATION, self, "confused_recover")
	register_timer("confused_recover", confused_recovering_timer)

	status_icons.confused.get_node("AnimationPlayer").play("Blink")

	unregister_timer("confused")

func confused_recover():
	status.confused = false
	status_icons.confused.visible = false
	unregister_timer("confused_recover")

func knocked_back(vel_x, vel_y, x_fade_rate):
	if status.invincible || status.cc_immune || status.dead:
		return

	velocity_replacement_y = vel_y * self_knock_back_modifier
	additional_speed_x = vel_x * self_knock_back_modifier
	additional_speed_x_fading_rate = x_fade_rate * self_knock_back_modifier

func damaged(val, randomness = true):
	if status.dead:
		return

	if status.invincible:
		display_immune_text()
		return

	# Apply modifier.
	var rand_ratio = (1.0 + rng.randf_range(-DAMAGE_TAKEN_RAND_RATIO, DAMAGE_TAKEN_RAND_RATIO)) if randomness else 1
	val = int(val * defense_modifier * rand_ratio)

	# Damaged animation (modulate color).
	if hurt_modulate_timer == null:
		var curr_modulate = null
		for node_path in player_constants.hurt_modulate_node_path:
			if curr_modulate == null:
				curr_modulate = get_node(node_path).modulate
			get_node(node_path).modulate = player_constants.hurt_modulate_color

		hurt_modulate_timer = countdown_timer.new(HURT_MODULATE_DURATION, self, "recover_modulate", curr_modulate)

	# Number indicator.
	var num = number_indicator.instance()
	num.initialize(val, DAMAGE_NUMBER_COLOR, number_spawn_pos, self)

	health_system.change_health_by(-val)
	health_bar.set_health_bar(health_system.health)

func recover_modulate(original_modulate):
	for node_path in player_constants.hurt_modulate_node_path:
		get_node(node_path).modulate = original_modulate
	hurt_modulate_timer = null

func ghost_damaged(val):
	ghost_health = max(0, ghost_health - val)
	health_bar.set_dead_health(ghost_health)

	number_indicator.instance().initialize(val, GHOST_DAMAGE_NUMBER_COLOR, number_spawn_pos, self)

	if ghost_health == 0:
		revive()

func healed(val):
	if status.dead:
		return

	health_system.change_health_by(val)
	health_bar.set_health_bar(health_system.health)

	# Number indicator.
	var num = number_indicator.instance()
	num.initialize(val, HEAL_NUMBER_COLOR, number_spawn_pos, self)

func die():
	status.dead = true

	# Discard unused ult.
	if status.has_ult:
		release_ult()
		status.has_ult = false

	play_animation("Die")
	set_status("can_move", false, DIE_ANIMATION_DURATION)
	die_timer = countdown_timer.new(DIE_ANIMATION_DURATION, $"../HeroManager", "hero_dead")
	
	# Show ghost health bar only if its in coop mode.
	if $"../HeroManager".heroes.size() > 1:
		ghost_health = player_constants.ghost_health
		health_bar.switch_to_dead_health_bar()
		health_bar.set_dead_health(ghost_health)

	ghost_hit_box.activate()

func revive():
	animator.play_backwards("Die")

	add_child(lightning.instance())

	following_camera.start_shake_effect()

	set_status("can_move", false, DIE_ANIMATION_DURATION)
	set_status("dead", true, DIE_ANIMATION_DURATION)

	$"../HeroManager".dead_hero_count -= 1

	health_system.restore_to_full_health()
	health_bar.switch_from_dead_to_original_health_bar()
	health_bar.set_health_bar(health_system.health)

	ghost_hit_box.deactivate()

func get_side():
	return int(sign(sprite.scale.x))

func get_size():
	return scale.x

func jump_to_height(height):
	velocity_replacement_y = -pow(2.0 * height * gravity, 0.5)

func reset_alpha_and_teleport_to_position(pos):
	var lerper = opacity_lerper.instance()
	lerper.initialize(0.0, 1.0, PORTAL_DURATION)
	add_child(lerper)
	
	global_position = pos