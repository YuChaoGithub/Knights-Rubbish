extends Node2D

export(String, FILE) var player_constants_filepath
export(NodePath) var defense_icon_path
export(NodePath) var damage_icon_path
export(NodePath) var slowed_icon_path
export(NodePath) var speeded_icon_path
export(NodePath) var confused_icon_path

# The amount of time (in seconds) to play idle animation.
const TIME_TO_IDLE_ANIMATION = 5

# Grabbing and dropping.
const GRABBING_DURATION = 1.0
const DROPPING_DURATION = 3.5
const FALL_OFF_DAMAGE = 100

# The actual damage taken will be 20% less or more randomly.
const DAMAGE_TAKEN_RAND_RATIO = 0.2

const HURT_MODULATE_DURATION = 0.15
const DAMAGE_NUMBER_COLOR = Color(255.0 / 255.0, 0.0 / 255.0, 210.0 / 255.0)
const HEAL_NUMBER_COLOR = Color(110.0 / 255.0, 240.0 / 255.0, 15.0 / 255.0)
const STUNNED_TEXT_COLOR = Color(180.0 / 255.0, 180.0 / 255.0, 0.0 / 255.0)
const IMMUNE_TEXT_COLOR = Color(255.0 / 255.0, 230.0 / 255.0, 0.0 / 255.0)

# Controls the basic animations (walk, jump, idle, etc.) of characters.
# The name of the default animator is defined in player_constants.
# Loaded in _ready().
var animator

# Record the time which the player is idle.
var idle_timestamp

# Sprite node (the parent node of the animator).
# Loaded in _ready().
var sprite

# Calculated values, so that movement could be done more conveniently.
var gravity
var jump_speed
var speed

# State modifier (could be changed by power ups, debuffs, or skill).
var movement_speed_modifier = 1.0
var damage_modifier = 1.0
var defense_modifier = 1.0
var self_knock_back_modifier = 1.0
var enemy_knock_back_modifier = 1.0

# For knockback or movement skills.
var additional_speed_x = 0
var additional_speed_x_fading_rate = 0

# Velocity replacement for verticle movement skills (note that the velocity would only be replaced once).
var velocity_replacement_y = null

# Current velocity of the character.
var velocity = Vector2(0, 0)

# Functions which would be called when jumping.
# Should be in the form of [Object, "func_name"].
var jump_event = []

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
	cc_immune = false
}

# Calculated in every frame. Some skills may use the value.
var landed_on_ground = false

var countdown_timer = preload("res://Scripts/Utils/CountdownTimer.gd")
var rng = preload("res://Scripts/Utils/RandomNumberGenerator.gd")

# Active timers for power ups.
# For cancelling timers for conflicting power ups/state changes.
# The data should be saved as dictionaries {tag:String -> CountdownTimer}.
var active_timers = {}

var speed_timers = {} # Label -> {timer, multiplier}
var speed_timer_label = 0
var slowed_count = 0
var speeded_count = 0
var hurt_modulate_timer = null
var fall_off_timer = null
var top_fist = null

# Child nodes.
onready var collision_handler = get_node("Collision Handler")
onready var combo_handler = get_node("Combo Handler")

# Character Average Position (used to control the following camera.)
onready var char_average_pos = get_node("../Character Average Position")

# Camera. For clamping within view bounds.
onready var following_camera = get_node("../Following Camera")

# Character stats.
onready var player_constants = load(player_constants_filepath)

# Manages healing, damaging, dying.
onready var health_system = preload("res://Scripts/Utils/HealthSystem.gd").new(self, player_constants.full_health)
onready var avatar_texture = load("res://Graphics/UI/Avatar/" + player_constants.name + ".png")

# Particles.
onready var fire_particle = get_node(player_constants.fire_particle_node_path)
onready var ult_eyes = get_node(player_constants.ult_eyes_node_path)

# Damage, heal numbers indicator.
var number_indicator = preload("res://Scenes/Utils/Numbers/Number Indicator.tscn")
onready var number_spawn_pos = get_node("Number Spawn Pos")

onready var health_bar = get_node("Health Bar")

onready var status_icons = {
	defense = get_node(defense_icon_path),
	damage = get_node(damage_icon_path),
	slowed = get_node(slowed_icon_path),
	confused = get_node(confused_icon_path),
	speeded = get_node(speeded_icon_path)
}

func _ready():
	# Configure movement related variables.
	recalculate_horizontal_movement_variables()
	recalculate_vertical_movement_variables()
	
	# Default animator.
	sprite = get_node("Sprite")
	animator = sprite.get_node(player_constants.default_animator_path)

	# Hide all status icons.
	for icon in status_icons:
		status_icons[icon].hide()

	# Hide all particles.
	fire_particle.hide()

	# Initialize timestamp.
	idle_timestamp = OS.get_unix_time()

	# Register itself to character average position.
	char_average_pos.characters.push_back(self)
	char_average_pos.add_character(get_global_pos())

	# Health bar.
	health_bar.initialize(player_constants.full_health, avatar_texture)

	set_process(true)

func _process(delta):
	check_combo_and_perform()
	update_movement(delta)

# Move by keyboard inputs. Also play movement animations.
# Calculate the movement and pass it to Collision Handler. Set the position as the returned value and update the camera.
func update_movement(delta):
	# For debugging only.
	if Input.is_action_pressed("debug_stun"):
		stunned(2)

	if status.no_movement:
		return

	# The movement animation name (key) supposed to be played.
	var animation_key = null

	landed_on_ground = collision_handler.collided_sides[collision_handler.BOTTOM]

	# Play the "Still" animation if the player is currently landed on the ground.
	# Else, play the "Jump" animation (when in air).
	if landed_on_ground:
		animation_key = "Still"
	else:
		animation_key = "Jump"

	# If hit above or hit below, reset velocity.
	if collision_handler.collided_sides[collision_handler.TOP] or landed_on_ground:
		velocity.y = 0
	
	var horizontal_movement = 0
	
	if status.can_move:
		# Horizontal keyboard input.
		if Input.is_action_pressed("player_left"):
			horizontal_movement += (1 if status.confused else -1)
		if Input.is_action_pressed("player_right"):
			horizontal_movement += (-1 if status.confused else 1)

		# In fist.
		if top_fist != null:
			top_fist.perform_movement(horizontal_movement, delta)

			var final_pos = top_fist.get_drop_pos()
			char_average_pos.update_pos(get_global_pos(), final_pos)
			set_global_pos(final_pos)
			return
 
		# Override the "Still" animation if the character is walking (on the ground).
		if horizontal_movement != 0 and landed_on_ground:
			animation_key = "Walk"
			
		# Jumping.
		if Input.is_action_pressed("player_jump") and status.can_jump and collision_handler.collided_sides[collision_handler.BOTTOM]:
			velocity.y += jump_speed
			
			# Triggers events when jumping.
			for obj_func in jump_event:
				obj_func[0].call(obj_func[1])
	
	# Change the x scale of the sprite according to which side the character is facing.
	if horizontal_movement != 0 and sign(sprite.get_scale().x) != horizontal_movement:
		sprite.set_scale(Vector2(sprite.get_scale().x * -1, sprite.get_scale().y))

	# Apply vertical velocity modifier if there is one.
	if velocity_replacement_y != null:
		velocity.y = velocity_replacement_y

		# Only apply this velocity once.
		velocity_replacement_y = null
	
	# Reduce additional speed x.
	additional_speed_x = sign(additional_speed_x) * max(0, abs(additional_speed_x) - abs(delta * additional_speed_x_fading_rate))

	velocity.x = horizontal_movement * speed + additional_speed_x
	velocity.y += gravity * delta
	
	# Pass to the collision handler, and get the collision-modified movement from its return value.
	var final_pos = get_global_pos() + collision_handler.movement_after_collision(velocity * delta)

	# Pass to the following camera, so that the character won't go beyond the camera.
	var camera_clamped_pos = following_camera.clamp_pos_within_cam_bounds(final_pos)
	
	# Fall off check.
	if !status.fallen_off && camera_clamped_pos.y < final_pos.y:
		falls_off()
	
	final_pos = camera_clamped_pos
	
	# Update Character Average Position (so that the camera is updated).
	char_average_pos.update_pos(get_global_pos(), final_pos)

	# Update the position of the character.
	set_global_pos(final_pos)

	# Play the movement animation if no skill animation is currently being played.
	if status.animate_movement && animation_key != null:

		# Play idle animation if the character waits for too long.
		if animation_key == "Still" && OS.get_unix_time() - idle_timestamp >= TIME_TO_IDLE_ANIMATION:
			play_animation("Idle")
		else:
			play_animation(animation_key)

# Falls off the bottom of the screen.
func falls_off():
	status.fallen_off = true

	following_camera.cam_lock_semaphore += 1

	combo_handler.cancel_skills_when_falling_off()
	damaged(FALL_OFF_DAMAGE, false)

	hide()
	following_camera.instance_bottom_grab(get_global_pos().x)

	set_status("can_move", false, GRABBING_DURATION)
	set_status("can_cast_skill", false, GRABBING_DURATION + DROPPING_DURATION)
	set_status("no_movement", true, GRABBING_DURATION)
	set_status("can_jump", false, GRABBING_DURATION + DROPPING_DURATION)
	set_status("invincible", true, GRABBING_DURATION + DROPPING_DURATION)

	fall_off_timer = countdown_timer.new(GRABBING_DURATION, self, "show_fist")

func show_fist():
	top_fist = following_camera.instance_top_fist()
	
	fall_off_timer = countdown_timer.new(DROPPING_DURATION, self, "drop_from_fist")

func drop_from_fist():
	status.fallen_off = false

	velocity = Vector2(0.0, 0.0)

	following_camera.cam_lock_semaphore -= 1

	top_fist.release()
	
	var original_z = get_z()
	set_z(top_fist.get_z() + 1)
	show()

	top_fist = null
	fall_off_timer = countdown_timer.new(0.5, self, "set_z", original_z)
	
# Perform combo by its function name.
func check_combo_and_perform():
	if Input.is_action_pressed("player_ult"):
		# Ult.
		combo_handler.ult()
	elif Input.is_action_pressed("player_skill"):
		# Skills.
		if Input.is_action_pressed("player_left"):
			combo_handler.horizontal_skill(-1)
		elif Input.is_action_pressed("player_right"):
			combo_handler.horizontal_skill(1)
		elif Input.is_action_pressed("player_up"):
			combo_handler.up_skill()
		elif Input.is_action_pressed("player_down"):
			combo_handler.down_skill()
		else:
			combo_handler.basic_skill()
	elif Input.is_action_pressed("player_attack"):
		# Attack.
		combo_handler.basic_attack()

func gain_ult():
	status.has_ult = true
	health_bar.change_to_ult_theme()
	ult_eyes.show()

	for eye_path in player_constants.eyes_node_path:
		get_node(eye_path).hide()

func release_ult():
	status.has_ult = false
	health_bar.change_to_ordinary_theme()
	ult_eyes.hide()

	for eye_path in player_constants.eyes_node_path:
		get_node(eye_path).show()

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

# Play the animation if it isn't played currently.
func play_animation(key):
	# Rest idle timer if the animation currently played isn't idle itself.
	if key != "Idle" && key != "Still":
		idle_timestamp = OS.get_unix_time()

	if animator.get_current_animation() != key:
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
	sprite.set_scale(Vector2(abs(sprite.get_scale().x) * side, sprite.get_scale().y))

func display_immune_text():
	var immune_text = number_indicator.instance()
	immune_text.initialize(-2, IMMUNE_TEXT_COLOR, number_spawn_pos, self)

func show_ignited_particles(duration):
	var ignite_timer = countdown_timer.new(duration, self, "ignited_recover")
	register_timer("ignite", ignite_timer)

	fire_particle.show()

func ignited_recover():
	unregister_timer("ignite")
	fire_particle.hide()

# Common abnormal status.
func defense_boosted(multiplier, duration):
	var defense_timer = countdown_timer.new(duration, self, "defense_boost_recover", multiplier)
	register_timer("defense_change", defense_timer)

	defense_modifier *= multiplier

	status_icons.defense.show()
	status_icons.defense.get_node("AnimationPlayer").play("Pop")

func defense_boost_recover(multiplier):
	defense_modifier /= multiplier
	status_icons.defense.hide()
	unregister_timer("defense_change")

func damage_boosted(multiplier, duration):
	var damage_timer = countdown_timer.new(duration, self, "damage_boost_recover", multiplier)
	register_timer("damage_change", damage_timer)

	damage_modifier *= multiplier

	status_icons.damage.show()
	status_icons.damage.get_node("AnimationPlayer").play("Pop")

func damage_boost_recover(multiplier):
	damage_modifier /= multiplier
	status_icons.damage.hide()
	unregister_timer("damage_change")

func dwarfed_or_gianted(multipliers, duration):
	var dwarf_giant_timer = countdown_timer.new(duration, self, "dwarf_giant_recover", multipliers)
	register_timer("giant_dwarf_potion", dwarf_giant_timer)

	set_size(multipliers.size)
	defense_modifier *= multipliers.defense
	damage_modifier *= multipliers.damage
	self_knock_back_modifier *= multipliers.self_knock_back
	enemy_knock_back_modifier *= multipliers.enemy_knock_back

func dwarf_giant_recover(multipliers):
	set_size(1.0)
	defense_modifier /= multipliers.defense
	damage_modifier /= multipliers.damage
	self_knock_back_modifier /= multipliers.self_knock_back
	enemy_knock_back_modifier /= multipliers.enemy_knock_back

	unregister_timer("giant_dwarf_potion")

func set_size(multiplier):	
	# Update the actual size.
	set_scale(Vector2(1.0, 1.0) * multiplier)
	
	# Reset collision raycast origins.
	collision_handler.calculate_ray_spacings()

func speed_changed(multiplier, duration):
	# Cannot be slowed while invincible.
	if status.invincible && multiplier < 1.0:
		return

	movement_speed_modifier *= multiplier
	recalculate_horizontal_movement_variables()

	var speed_timer = countdown_timer.new(duration, self, "speed_change_recover", speed_timer_label)

	if multiplier < 1:
		status_icons.slowed.show()
		status_icons.slowed.get_node("AnimationPlayer").play("Pop")
		slowed_count += 1
	else:
		status_icons.speeded.show()
		speeded_count += 1

	speed_timers[speed_timer_label] = {
		timer = speed_timer,
		multiplier = multiplier
	}
	speed_timer_label += 1

func speed_change_recover(label):
	var speed_data = speed_timers[label]
	movement_speed_modifier /= speed_data.multiplier
	recalculate_horizontal_movement_variables()

	if speed_data.multiplier < 1:
		slowed_count -= 1
		if slowed_count == 0:
			status_icons.slowed.hide()
	else:
		speeded_count -= 1
		if speeded_count == 0:
			status_icons.speeded.hide()

	speed_timers.erase(label)

func stunned(duration):
	# Can't be stunned while invincible.
	if status.invincible || status.cc_immune:
		display_immune_text()
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

	# Interrupt skills if any.
	if active_timers.has("interruptable_skill"):
		active_timers["interruptable_skill"].destroy_timer()
		active_timers.erase("interruptable_skill")

	play_animation("Stunned")

func confused(duration):
	if status.invincible || status.cc_immune:
		display_immune_text()
		return

	status.confused = true

	status_icons.confused.show()
	status_icons.confused.get_node("AnimationPlayer").play("Pop")

	var confused_timer = countdown_timer.new(duration, self, "cancel_confused")
	register_timer("confused", confused_timer)

func cancel_confused():
	status.confused = false
	status_icons.confused.hide()
	unregister_timer("confused")

func knocked_back(vel_x, vel_y, x_fade_rate):
	if status.invincible || status.cc_immune:
		return

	velocity_replacement_y = vel_y * self_knock_back_modifier
	additional_speed_x = vel_x * self_knock_back_modifier
	additional_speed_x_fading_rate = x_fade_rate * self_knock_back_modifier

func damaged(val, randomness = true):
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
				curr_modulate = get_node(node_path).get_modulate()
			get_node(node_path).set_modulate(player_constants.hurt_modulate_color)

		hurt_modulate_timer = countdown_timer.new(HURT_MODULATE_DURATION, self, "recover_modulate", curr_modulate)

	# Number indicator.
	var num = number_indicator.instance()
	num.initialize(val, DAMAGE_NUMBER_COLOR, number_spawn_pos, self)

	health_system.change_health_by(-val)
	health_bar.set_health_bar(health_system.health)

func recover_modulate(original_modulate):
	for node_path in player_constants.hurt_modulate_node_path:
		get_node(node_path).set_modulate(original_modulate)
	hurt_modulate_timer = null

func healed(val):
	health_system.change_health_by(val)
	health_bar.set_health_bar(health_system.health)

	# Number indicator.
	var num = number_indicator.instance()
	num.initialize(val, HEAL_NUMBER_COLOR, number_spawn_pos, self)

func die():
	print("I died. QQ")