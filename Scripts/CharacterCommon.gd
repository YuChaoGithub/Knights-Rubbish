extends Node2D

export(String, FILE) var player_constants_filepath

# Loaded in ready().
var player_constants

# Hit points. When reaches zero, the character dies.
var health setget set_health

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

# Current velocity of the character.
var velocity = Vector2(0, 0)

# Whether the player can move or not.
var can_move = true

# Player won't take damage if invincible is true.
var invincible = false

# Active timers for power ups.
# For cancelling timers for conflicting power ups.
# The data should be saved as dictionaries {tag(String): CountdownTimer}.
var active_timers = {}

# Child nodes.
onready var collision_handler = get_node("Collision Handler")
onready var combo_handler = get_node("Combo Handler")

# Camera
onready var following_camera = get_node("../Following Camera")

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
	
# Set the value of health. (eg. Being attacked, being healed.)
func set_health(value):
	var new_health
	
	# More than max health.
	if value > player_constants.full_health:
		new_health = player_constants.full_health
	elif value <= 0:
		# Die.
		new_health = 0
		
	# Set the health.
	health = new_health

func _ready():
	player_constants = load(player_constants_filepath)
	
	# Set to full health.
	health = player_constants.full_health
	
	# Configure movement related variables.
	recalculate_horizontal_movement_variables()
	recalculate_vertical_movement_variables()

	set_process(true)

func _process(delta):
	check_combo_and_perform()
	update_movement(delta)

# Move by keyboard inputs.
# Calculate the movement and pass it to Collision Handler. Set the position as the returned value and update the camera.
func update_movement(delta):
	# If hit above or hit below, reset velocity.
	if collision_handler.collided_sides[collision_handler.TOP] or collision_handler.collided_sides[collision_handler.BOTTOM]:
		velocity.y = 0
	
	var horizontal_movement = 0
	
	if can_move:
		# Horizontal keyboard input.
		if Input.is_action_pressed("player_left"):
			horizontal_movement -= 1
		if Input.is_action_pressed("player_right"):
			horizontal_movement += 1
			
		# Jumping.
		if Input.is_action_pressed("player_jump") and collision_handler.collided_sides[collision_handler.BOTTOM]:
			velocity.y += jump_speed
		
	velocity.x = horizontal_movement * speed
	velocity.y += gravity * delta
	
	# Pass to the collision handler, and get the collision-modified movement from its return value.
	translate(collision_handler.movement_after_collision(velocity * delta))
	
	# Update following camera.
	following_camera.check_camera_update(get_global_pos())
	
# Perform combo by its function name.
func check_combo_and_perform():
	if Input.is_action_pressed("player_attack"):
		# Attack.
		if Input.is_action_pressed("player_left"):
			combo_handler.left_attack()
		elif Input.is_action_pressed("player_right"):
			combo_handler.right_attack()
		elif Input.is_action_pressed("player_up"):
			combo_handler.up_attack()
		elif Input.is_action_pressed("player_down"):
			combo_handler.down_attack()
		elif Input.is_action_pressed("player_skill"):
			combo_handler.ult()
		else:
			combo_handler.basic_attack()
	elif Input.is_action_pressed("player_skill"):
		# Skill.
		if Input.is_action_pressed("player_left"):
			combo_handler.left_skill()
		elif Input.is_action_pressed("player_right"):
			combo_handler.right_skill()
		elif Input.is_action_pressed("player_up"):
			combo_handler.up_skill()
		elif Input.is_action_pressed("player_down"):
			combo_handler.down_skill()
		else:
			combo_handler.basic_skill()

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