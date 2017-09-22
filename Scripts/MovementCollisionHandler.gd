extends Area2D

const SKIN_WIDTH = 3
const HORIZONTAL_RAY_COUNT = 5
const VERTICAL_RAY_COUNT = 5
const MAX_CLIMBING_ANGLE = 60

const DESCENDING_SLOPE_RAY_LENGTH = 50

# Stores the spacing between each rays.
var horizontal_spacing
var vertical_spacing

# Stores the 4 corners of the collision box.
enum { LOWER_LEFT, UPPER_LEFT, UPPER_RIGHT, LOWER_RIGHT }
var box_corners = {}

# Record slope info.
var climbing_slope = false
var descending_slope = false
var climbing_angle_old
var climbing_angle
var velocity_old

# Stores the sides collided.
enum { LEFT, TOP, RIGHT, BOTTOM }
var collided_sides = { LEFT: false, TOP: false, RIGHT: false, BOTTOM: false }

# Get the global node for collision masks.
onready var collision_layers = Globals.get("Platform Layer") | Globals.get("Camera Bounds Layer")

# The collision 2D child node.
onready var collision_box = get_node("Collision Box")

# Space state for raycasting
onready var space_state = get_world_2d().get_direct_space_state()

var debug_draws = []

func _draw():
	for debug_draw in debug_draws:
		draw_line(debug_draw["from"] - get_global_pos(), debug_draw["to"] - get_global_pos(), Color(0, 255, 0) , 3.0)
	debug_draws = []
	
func _process(delta):
	update()

func _ready():
	calculate_ray_spacings()
	set_process(true)
	
# Being called by other scripts to return collision applied movement.
func movement_after_collision(movement):
	update_box_corners()
	reset_collided_sides()
	
	# For consecutive climbing and descending slopes.
	velocity_old = movement
	
	# Slope descending.
	if movement.y > 0:
		movement = descend_slope(movement)
	
	# Horizontal Collision.
	if movement.x != 0:
		movement = horizontal_collision(movement)
	
	# Vertical Collision.
	if movement.y != 0:
		movement = vertical_collision(movement)
	
	return movement

# Calculate and return the position where the box should be.
# Taking account horizontal collisions.
func horizontal_collision(velocity):
	var dir_x = sign(velocity.x)
	var ray_length = abs(velocity.x) + SKIN_WIDTH
	
	# Start casting rays.
	for i in range(HORIZONTAL_RAY_COUNT):
		var starting_point = box_corners[UPPER_RIGHT] if dir_x > 0 else box_corners[UPPER_LEFT]
		
		# Calculate the starting position of the ray.
		starting_point += Vector2(0, horizontal_spacing * i)
		
		# Cast ray.
		var ray_hit = space_state.intersect_ray(starting_point, starting_point + Vector2(ray_length * dir_x, 0), [self], collision_layers)
		
		# For Debug Use.
		debug_draws.append({"to": starting_point, "from": starting_point + Vector2(ray_length * dir_x * 5, 0)})
		
		# Check if hit. (ray_hit is a dictionary)
		if ray_hit.size() > 0:
			var hit_length = abs(ray_hit.position.x - starting_point.x)
			
			# Check if it is a slope.
			var slope_angle = rad2deg(acos(Vector2(0, -1).dot(ray_hit.normal)))
			
			# Check if it is the bottom most ray. If it is, check if it can climb the slope.
			if i == HORIZONTAL_RAY_COUNT - 1 and slope_angle <= MAX_CLIMBING_ANGLE:
				
				# Cancel descending slope.
				if descending_slope:
					descending_slope = false
					velocity = velocity_old
				
				# Move until the truly touches the slope.
				var distance_to_slope = 0
				if slope_angle != climbing_angle_old:
					distance_to_slope = hit_length - SKIN_WIDTH
					velocity.x -= distance_to_slope * dir_x
				
				velocity = climb_slope(velocity, slope_angle)
				velocity.x += distance_to_slope * dir_x
			
			# Hit unclimbable obstacles.
			if not climbing_slope or slope_angle > climbing_angle:
				velocity.x = (hit_length - SKIN_WIDTH) * dir_x
				
				# Avoid other rays casting to farther platforms.
				ray_length = hit_length
				
				# Hit obstacles when climbing slope, should update dy to correctly dectect collision.
				if climbing_slope:
					velocity.y = tan(deg2rad(climbing_angle)) * abs(velocity.x)
				
				# Set collided sides.
				if dir_x == 1:
					collided_sides[RIGHT] = true
				else:
					collided_sides[LEFT] = true
			
	# Return the newest velocity.
	return velocity

# Calculate and return the position where the box should be.
# Taking account vertical collisions.
func vertical_collision(velocity):
	var dir_y = sign(velocity.y)
	var ray_length = abs(velocity.y) + SKIN_WIDTH
	
	# Start casting rays.
	for i in range(VERTICAL_RAY_COUNT):
		var starting_point = box_corners[LOWER_LEFT] if dir_y > 0 else box_corners[UPPER_LEFT]
		
		# Calculate the starting position of the ray.
		starting_point += Vector2(vertical_spacing * i + velocity.x, 0)
		
		# Cast ray.
		var ray_hit = space_state.intersect_ray(starting_point, starting_point + Vector2(0, ray_length * dir_y), [self], collision_layers)
		
		# For Debug Use.
		debug_draws.append({"to": starting_point, "from": starting_point + Vector2(0, ray_length * dir_y * 5)})
		
		# Check if hit. (ray_hit is a dictionary)
		if ray_hit.size() > 0:
			var hit_length = abs(ray_hit.position.y - starting_point.y)
			velocity.y = (hit_length - SKIN_WIDTH) * dir_y
			
			# Avoid other rays casting to farther platforms.
			ray_length = hit_length
			
			# Hit obstacles while climbing slope.
			if climbing_slope:
				velocity.x = abs(velocity.y) / tan(deg2rad(climbing_angle)) * (1 if velocity.x > 0 else -1)
			
			# Set collided side.
			if dir_y == 1:
				collided_sides[BOTTOM] = true
			else:
				collided_sides[TOP] = true
			
	# Adjacent slopes.
	if climbing_slope:
		var dir_x = 1 if velocity.x >= 0 else -1
		ray_length = abs(velocity.x) + SKIN_WIDTH
		var ray_origin = (box_corners[LOWER_LEFT] if dir_x == -1 else box_corners[LOWER_RIGHT]) + Vector2(0, velocity.y)
		var hit = space_state.intersect_ray(ray_origin, ray_origin + Vector2(ray_length * dir_x, 0), [self], collision_layers)
		
		# For Debug Use
		#debug_draws.append({"to": ray_origin, "from": ray_origin + Vector2(ray_length * dir_x * 5, 0)})
		
		# Hit a new slope.
		if hit.size() > 0:
			var slope_angle = rad2deg(acos(Vector2(0, -1).dot(hit.normal)))
			if slope_angle != climbing_angle:
				velocity.x = (abs(hit.position.x - ray_origin.x) - SKIN_WIDTH) * dir_x
				climbing_angle = slope_angle
	
	# Return the newest velocity.
	return velocity
	
# Returns the velocity of slope climbing.
func climb_slope(velocity, slope_angle):
	var move_distance = abs(velocity.x)
	var climb_velocity_y = -sin(deg2rad(slope_angle)) * move_distance
	
	# If not jumping (Note: negative y is upward!).
	if velocity.y >= climb_velocity_y:
		velocity.y = climb_velocity_y
		velocity.x = cos(deg2rad(slope_angle)) * move_distance * (1 if velocity.x >= 0 else -1)
		collided_sides[BOTTOM] = true
		
		# Store climbing info.
		climbing_slope = true
		climbing_angle = slope_angle
		
		
	# Return the new velocity.
	return velocity
	
# Returns the velocity of slope descending.
func descend_slope(velocity):
	var dir_x = sign(velocity.x)
	var ray_origin = box_corners[LOWER_LEFT] if dir_x == 1 else box_corners[LOWER_RIGHT]
	
	# Cast a ray downward.
	var ray_hit = space_state.intersect_ray(ray_origin, ray_origin + Vector2(0, DESCENDING_SLOPE_RAY_LENGTH), [self], collision_layers)

	# For Debug Use.
	#debug_draws.append({"to": ray_origin, "from": ray_origin + Vector2(0, DESCENDING_SLOPE_RAY_LENGTH)})

	if ray_hit.size() > 0:
		var slope_angle = rad2deg(acos(Vector2(0, -1).dot(ray_hit.normal)))
		if slope_angle != 0 and slope_angle <= MAX_CLIMBING_ANGLE:
			if sign(ray_hit.normal.x) == dir_x:
				if abs(ray_hit.position.y - ray_origin.y) - SKIN_WIDTH <= tan(deg2rad(slope_angle)) * abs(velocity.x):
					var move_distance = abs(velocity.x)
					var descend_velocity_y = sin(deg2rad(slope_angle)) * move_distance
					velocity.x = cos(deg2rad(slope_angle)) * move_distance * sign(velocity.x)
					velocity.y += descend_velocity_y
					
					climbing_angle = slope_angle
					descending_slope = true
					collided_sides[BOTTOM] = true
					
	return velocity
	
func calculate_ray_spacings():
	# Get the bounding box of the collision box.
	var box_extent = collision_box.get_shape().get_extents() * get_global_scale()
	var bounding_box = Rect2(-box_extent.x, -box_extent.y, 2 * box_extent.x, 2 * box_extent.y).grow(-SKIN_WIDTH)
	
	# Calculate ray spacings.
	horizontal_spacing = bounding_box.size.height / (HORIZONTAL_RAY_COUNT - 1)
	vertical_spacing =  bounding_box.size.width / (VERTICAL_RAY_COUNT - 1)
	
func update_box_corners():
	# Get the bounding box of the collision box.
	var box_extent = collision_box.get_shape().get_extents() * get_global_scale()
	var bounding_box = Rect2(-box_extent.x, -box_extent.y, 2 * box_extent.x, 2 * box_extent.y).grow(-SKIN_WIDTH)
	
	# Set to box corners.
	box_corners[LOWER_LEFT] = get_global_pos() + Vector2(bounding_box.pos.x, bounding_box.pos.y + bounding_box.size.height)
	box_corners[UPPER_LEFT] = get_global_pos() + Vector2(bounding_box.pos.x, bounding_box.pos.y)
	box_corners[UPPER_RIGHT] = get_global_pos() + Vector2(bounding_box.pos.x + bounding_box.size.width, bounding_box.pos.y)
	box_corners[LOWER_RIGHT] = get_global_pos() + Vector2(bounding_box.pos.x + bounding_box.size.width, bounding_box.pos.y + bounding_box.size.height)
	
# Resets all the collided sides to false.
func reset_collided_sides():
	collided_sides[LEFT] = false
	collided_sides[TOP] = false
	collided_sides[RIGHT] = false
	collided_sides[BOTTOM] = false
	
	# Slope.
	climbing_slope = false
	descending_slope = false
	climbing_angle_old = climbing_angle
	climbing_angle = 0