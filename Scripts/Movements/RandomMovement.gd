var min_steps
var max_steps
var min_time_per_step
var max_time_per_step

var dx
var dy

var steps = []   # An array of durations.
var index = 0
var dir_x
var dir_y
var always_change_dir
var timestamp = 0.0

var rng = preload("res://Scripts/Utils/RandomNumberGenerator.gd")

func _init(dx, dy, always_change_dir = true, min_steps = 2, max_steps = 4, min_time_per_step = 0.25, max_time_per_step = 0.75):
    self.dx = dx
    self.dy = dy
    self.always_change_dir = always_change_dir
    self.min_steps = min_steps
    self.max_steps = max_steps
    self.min_time_per_step = min_time_per_step
    self.max_time_per_step = max_time_per_step
    
    rng.init_rand()
    generate_random_movements()

func generate_random_movements():
    var step_count = rng.randi_range(min_steps, max_steps + 1)
    dir_x = rng.randsign()
    dir_y = rng.randsign()
    
    for i in range(step_count):
        steps.push_back(rng.randf_range(min_time_per_step, max_time_per_step + 1))

# Should always check if the random movement ended by calling movement_ended().
func movement(curr_pos, delta):
    timestamp += delta

    var result = curr_pos + Vector2(dx * delta * dir_x, dy * delta * dir_y)

    if timestamp >= steps[index]:
        timestamp -= steps[index]
        index += 1
        if always_change_dir:
            dir_x = -dir_x
            dir_y = -dir_y
        else:
            dir_x = rng.randsign()
            dir_y = rng.randsign()

    return result

func movement_ended():
    return index >= steps.size()