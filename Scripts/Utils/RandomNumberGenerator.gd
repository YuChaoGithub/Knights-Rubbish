# Call this to randomize the pseudo random generator.
static func init_rand():
    randomize()

# Returns a random integer in the range of [min_val, max_val).
static func randi_range(min_val, max_val):
    return (randi() % (max_val - min_val)) + min_val

# Returns a random float in the range of [min_val, max_val].
static func randf_range(min_val, max_val):
    return (randf() * (max_val - min_val)) + min_val