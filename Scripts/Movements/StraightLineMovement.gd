# Displacement per second.
var dx
var dy

# Constructor.
func _init(dx, dy):
    self.dx = dx
    self.dy = dy

# Pass in the current position and delta time of the node.
# Returns the calculated position of the next frame.
func movement(curr_pos, delta):
    return Vector2(curr_pos.x + dx * delta, curr_pos.y + dy * delta)