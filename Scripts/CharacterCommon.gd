extends Node2D

export(String, FILE) var player_constants_filepath

# The amount of time (in seconds) to play idle animation.
const TIME_TO_IDLE_ANIMATION = 5

const HURT_MODULATE_DURATION = 0.15
const DAMAGE_NUMBER_COLOR = Color(255.0 / 255.0, 0.0 / 255.0, 210.0 / 255.0)
const HEAL_NUMBER_COLOR = Color(110.0 / 255.0, 240.0 / 255.0, 15.0 / 255.0)
const STUNNED_TEXT_COLOR = Color(180.0 / 255.0, 180.0 / 255.0, 0.0 / 255.0)

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
var size_modifier = 1.0 setget set_size_modifier
var movement_speed_modifier = 1.0 setget set_movement_speed_modifier
var jump_height_modifier = 1.0 setget set_jump_height_modifier
var damage_modifier = 1.0
var defense_modifier = 1.0

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
	no_movement = false
}

# Calculated in every frame. Some skills may use the value.
var landed_on_ground = false

var countdown_timer = preload("res://Scripts/Utils/CountdownTimer.gd")

# Active timers for power ups.
# For cancelling timers for conflicting power ups/state changes.
# The data should be saved as dictionaries {tag:String -> CountdownTimer}.
var active_timers = {}
var hurt_modulate_timer = null

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

# Damage, heal numbers indicator.
var number_indicator = preload("res://Scenes/Utils/Numbers/Number Indicator.tscn")
onready var number_spawn_pos = get_node("Number Spawn Pos")

# Getters and setters.
func set_movement_speed_modifier(value):
	movement_speed_modifier = value
	recalculate_horizontal_movement_variables()
	
func set_jump_height_modifier(value):
	jump_height_modifier = value
	recalculate_vertical_movement_variables()
	
func set_size_modifier(value):
	size_modifier = value
	
	# Update the actual size.
	set_scale(Vector2(1.0, 1.0) * value)
	
	# Reset collision raycast origins.
	collision_handler.calculate_ray_spacings()

func _ready():
	# Configure movement related variables.
	recalculate_horizontal_movement_variables()
	recalculate_vertical_movement_variables()

	# Default animator.
	sprite = get_node("Sprite")
	animator = sprite.get_node(player_constants.default_animator_path)

	# Initialize timestamp.
	idle_timestamp = OS.get_unix_time()

	# Register itself to character average position.
	char_average_pos.characters.push_back(self)
	char_average_pos.add_character(get_global_pos())

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
			horizontal_movement -= 1
		if Input.is_action_pressed("player_right"):
			horizontal_movement += 1

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
	final_pos = following_camera.clamp_pos_within_cam_bounds(final_pos)
	
	# Update Character Average Position (so that the camera is updated).
	char_average_pos.update_pos(get_global_pos(), final_pos)

	# Update the position of the character.
	set_global_pos(final_pos)

	# Play the movement animation if no skill animation is currently being played.
	if status.animate_movement and animation_key != null:

		# Play idle animation if the character waits for too long.
		if OS.get_unix_time() - idle_timestamp >= TIME_TO_IDLE_ANIMATION:
			play_animation("Idle")
		else:
			play_animation(animation_key)
	
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

# Configure movement related variables.
func recalculate_horizontal_movement_variables():
	speed = player_constants.movement_speed * movement_speed_modifier
	
func recalculate_vertical_movement_variables():
	gravity = 2 * player_constants.jump_height * jump_height_modifier / pow(player_constants.time_to_jump_to_highest, 2)
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

# Common abnormal status.
func stunned(duration):
	# Can't be stunned while invincible.
	if status.invincible:
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

	# Play animation.
	play_animation("Stunned")

func knocked_back(vel_x, vel_y, x_fade_rate):
	if status.invincible:
		return

	velocity_replacement_y = vel_y
	additional_speed_x = vel_x
	additional_speed_x_fading_rate = x_fade_rate

func damaged(val):
	if status.invincible:
		return

	# Apply modifier.
	val = val * defense_modifier

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

func recover_modulate(original_modulate):
	for node_path in player_constants.hurt_modulate_node_path:
		get_node(node_path).set_modulate(original_modulate)
	hurt_modulate_timer = null

func damaged_over_time(time_per_tick, total_ticks, damage_per_tick):
	if status.invincible:
		return
	
	health_system.change_health_over_time_by(time_per_tick, total_ticks, -damage_per_tick)

func healed(val):
	health_system.change_health_by(val)

	# Number indicator.
	var num = number_indicator.instance()
	num.initialize(val, HEAL_NUMBER_COLOR, number_spawn_pos, self)

func healed_over_time(time_per_tick, total_ticks, heal_per_tick):
	health_system.change_health_over_time_by(time_per_tick, total_ticks, heal_per_tick)

func die():
	print("I died. QQ")