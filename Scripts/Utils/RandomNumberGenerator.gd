# Call this to randomize the pseudo random generator.
static func init_rand():
    randomize()

# Returns a random integer in the range of [min_val, max_val).
static func randi_range(min_val, max_val):
    return (randi() % int(max_val - min_val)) + min_val

# Returns a random float in the range of [min_val, max_val].
static func randf_range(min_val, max_val):
    return (randf() * (max_val - min_val)) + min_val

# Returns 1 or -1 with equal chance.
static func randsign():
    return (1 if randi() % 2 == 0 else -1)

static func randvec_range(min_pos, max_pos):
    return Vector2(randi_range(min_pos.x, max_pos.x), randi_range(min_pos.y, max_pos.y))